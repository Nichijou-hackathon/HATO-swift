//
//  EmotionalArtView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

// EmotionView.swift

import SwiftUI
import SceneKit

struct EmotionalArtView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let emotionResponse: EmotionResponse
    let sourceTitle: String
    let sourceArtist: String
    
    @State private var scene: SCNScene?
    @State private var isLoading = true
    @State private var showModel = false
    @State private var isSaved = false
    
    
    private let converter = EmotionModelConverter()
    
    var body: some View {
        ZStack(alignment: .top){
            LinearGradient(
                colors: [Color(UIColor(hex: emotionResponse.color)).opacity(0.3), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                if showModel {
                    if isLoading {
                        ProgressView("モデルを準備中...")
                    } else if let scene = scene {
                        ZStack(alignment: .topTrailing){
                            
                            SceneView(
                                scene: scene,
                                options: [
                                    .autoenablesDefaultLighting,
                                    .allowsCameraControl
                                ]
                            )
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark")
                                        .imageScale(.large).padding()
                                        .background(.thinMaterial).clipShape(Circle())
                                }
                                
                                Spacer()
                            
                                Button(action: saveEmotion) { // ← ここで saveEmotion() を呼び出す
                                    Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                                        .imageScale(.large).padding()
                                        .background(.thinMaterial).clipShape(Circle())
                                }
                                .disabled(isSaved)
                                .animation(.spring(), value: isSaved)
                            }
                        }
                        
                    } else {
                        Text("モデルの準備に失敗しました。")
                    }
                } else {
                    Spacer()
                    VStack {
                        Text("あなたの感情が\n実体化されました！").font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center).padding()
                        if isLoading { ProgressView().padding() }
                        else {
                            Button(action: { withAnimation { self.showModel = true } }) {
                                Text("表示する")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth:.infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }.padding(.horizontal, 40)
                        }
                    }
                    Spacer()
                    Spacer()
                }
            }
            
            .padding()
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
        
        // 保存する新しいオブジェクトを作成
        let newEmotion = SavedEmotion(
            emotion: emotionResponse.emotion,
            colorCode: emotionResponse.color,
            modelFileName: modelFileName,
            sourceTitle: sourceTitle,
            sourceArtist: sourceArtist,
            timestamp: .now
        )
        
        // SwiftDataに挿入
        modelContext.insert(newEmotion)
        
        // 保存済み状態に更新
        isSaved = true
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        let b = CGFloat(hexNumber & 0x0000ff) / 255
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
