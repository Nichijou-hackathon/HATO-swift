//
//  SavedEmotionsListView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//


import SwiftUI
import SwiftData
import SceneKit

struct SavedEmotionListsView: View {
    @Query(sort: \SavedEmotion.timestamp, order: .reverse) private var emotions: [SavedEmotion]
    
    var body: some View {
        NavigationStack {
            List(emotions) { emotion in
                NavigationLink(destination: SavedEmotionsListView(emotion: emotion)) {
                    VStack(alignment: .leading) {
                        Text(emotion.emotion.capitalized)
                            .font(.headline)
                            .foregroundColor(Color(UIColor(hex: emotion.colorCode)))
                        Text("\(emotion.sourceTitle) - \(emotion.sourceArtist)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("HeArt Works")
        }
    }
}

struct SavedEmotionsListView: View {
    let emotion: SavedEmotion

    var body: some View {
        SceneView(
            scene: makeScene(),
            options: [.autoenablesDefaultLighting, .allowsCameraControl]
        )
        .navigationTitle(emotion.emotion.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func makeScene() -> SCNScene? {
        guard let scene = SCNScene(named: emotion.modelFileName) else {
            return nil
        }
        let color = UIColor(hex: emotion.colorCode)
        scene.rootNode.enumerateChildNodes { (node, _) in
            node.geometry?.materials.forEach { $0.diffuse.contents = color }
        }
        return scene
    }
}
