//
//  PhysicsHomeView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/21.
//
//
//  PhysicsHomeView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/21.
//

import SwiftUI
import SwiftData
import SceneKit
import CoreGraphics

struct PhysicsHomeView: View {
    @Query(
        FetchDescriptor<SavedEmotion>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)],
        ),
        animation: .default
    ) private var emotions: [SavedEmotion]
    
    @State private var scene: SCNScene?
    
    var body: some View {
        NavigationStack {
            if let scene = scene {
                
                SceneView(scene: scene)
                    .ignoresSafeArea(edges: .top)
            } else {
                ProgressView("シーンを準備中...")
            }
        }
        .task {
            initialSceneSetup()
        }
        .onChange(of: emotions) {
            updateEmotionNodes()
        }
    }
    
    private func initialSceneSetup() {
        let newScene = SCNScene()
        newScene.background.contents = UIColor.white
        newScene.physicsWorld.gravity = SCNVector3(x: 0, y: -15, z: 0)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 35)
        newScene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 20, z: 20)
        newScene.rootNode.addChildNode(lightNode)
        
        createPhysicsBoundaries(for: newScene)
        
        self.scene = newScene
        
        updateEmotionNodes()
    }
    
    private func updateEmotionNodes() {
        guard let scene = self.scene else { return }
        
        Task {
            scene.rootNode.childNodes.filter({ $0 is EmotionNode }).forEach { $0.removeFromParentNode() }
            
            for (index, emotion) in emotions.enumerated() {
                try? await Task.sleep(for: .seconds(0.2 * Double(index)))
                let modelNode = EmotionNode(emotion: emotion)
                let randomX = Float.random(in: -10...10)
                modelNode.position = SCNVector3(x: randomX, y: 30, z: 0)
                scene.rootNode.addChildNode(modelNode)
            }
        }
    }
    
    private func createPhysicsBoundaries(for scene: SCNScene) {
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.isHidden = false 
        scene.rootNode.addChildNode(floorNode)
        
        
        let wallGeometry = SCNPlane(width: 100, height: 100)
        
        let leftWall = SCNNode(geometry: wallGeometry)
        leftWall.position = SCNVector3(-20, 0, 0)
        leftWall.eulerAngles = SCNVector3(0, CGFloat.pi / 2, 0)
        leftWall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        leftWall.isHidden = true 
        scene.rootNode.addChildNode(leftWall)
        
        let rightWall = SCNNode(geometry: wallGeometry)
        rightWall.position = SCNVector3(20, 0, 0)
        rightWall.eulerAngles = SCNVector3(0, -CGFloat.pi / 2, 0)
        rightWall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        rightWall.isHidden = true
        scene.rootNode.addChildNode(rightWall)
    }
}
