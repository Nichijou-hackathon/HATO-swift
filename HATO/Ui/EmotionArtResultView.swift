//
//  EmotionArtResultView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

import SwiftUI
import SceneKit
import SwiftData

struct EmotionArtResultView: View {
    let emotionResponse: EmotionResponse
    let sourceTitle: String
    let sourceArtist: String
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var scene: SCNScene?
    @State private var isLoading = true
    @State private var showModel = false
    @State private var isSaved = false
    
    private let converter = EmotionModelConverter()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
        
            LinearGradient(
                colors: [Color(UIColor(hex: emotionResponse.color)).opacity(0.3), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if showModel {
                    
                    if isLoading {
                        ProgressView("モデルを準備中...")
                            .tint(.white)
                    } else if let scene = scene {
                        SceneView(
                            scene: scene,
                            options: [.autoenablesDefaultLighting, .allowsCameraControl]
                        )
                    } else {
                        Text("モデルの準備に失敗しました。")
                            .foregroundColor(.white)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("あなたの感情が\n実体化されました！")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding()
                        } else {
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    self.showModel = true
                                }
                            }) {
                                Text("表示する")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    Spacer()
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: saveEmotion) {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            .imageScale(.large)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                    .disabled(isSaved)
                    .animation(.spring(), value: isSaved)
                }
                .padding()
                Spacer()
            }
            .foregroundColor(.primary)
        }
        .task {
            await configureScene()
        }
    }

    private func configureScene() async {
        let fileName = converter.modelFileName(for: emotionResponse.emotion)
        
        guard let loadedScene = SCNScene(named: fileName) else {
            print("モデルファイルの読み込みに失敗: \(fileName)")
            self.isLoading = false
            return
        }
        
        let color = UIColor(hex: emotionResponse.color)
        
        loadedScene.rootNode.enumerateChildNodes { (node, stop) in
            if let geometry = node.geometry {
                geometry.materials.forEach { material in
                    material.diffuse.contents = color
                }
            }
        }
        
        self.scene = loadedScene
        self.isLoading = false
    }

    private func saveEmotion() {
        let modelFileName = converter.modelFileName(for: emotionResponse.emotion)
        
        let newEmotion = SavedEmotion(
            emotion: emotionResponse.emotion,
            colorCode: emotionResponse.color,
            modelFileName: modelFileName,
            sourceTitle: sourceTitle,
            sourceArtist: sourceArtist,
            timestamp: .now
        )
        modelContext.insert(newEmotion)
        
        isSaved = true
    }
}

