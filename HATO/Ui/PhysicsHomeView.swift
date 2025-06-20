//
//  PhysicsHomeView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/21.
//

import SwiftUI
import SwiftData
import SceneKit

struct PhysicsHomeView: View {
    @Query(
        FetchDescriptor<SavedEmotion>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        ),
        animation: .default
    ) private var emotions: [SavedEmotion]
    
    @State private var scene = SCNScene()
    @State private var selectedEmotion: SavedEmotion?
    
    var body: some View {
        NavigationStack {
            sceneView
                .ignoresSafeArea()
                .task {
                    setupScene()
                }
        }
    }
    
    private var sceneView: some View {
            SceneView(scene: scene)
            .navigationDestination(item: $selectedEmotion) { emotion in
                SavedEmotionsListView(emotion: emotion)
            }
        }
    
    private func setupScene() {
        scene.background.contents = UIColor.white
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: -15, z: 0)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 35)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 20, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        createPhysicsBoundaries()
        
        Task {
                    scene.rootNode.childNodes.filter({ $0 is EmotionNode }).forEach { $0.removeFromParentNode() }
                    
                    for (index, emotion) in emotions.enumerated() {
                        try? await Task.sleep(for: .seconds(0.2 * Double(index)))
                        
                        let sphereNode = EmotionNode(emotion: emotion)
                        
                        let randomX = Float.random(in: -10...10)
                        sphereNode.position = SCNVector3(x: randomX, y: 30, z: 0)
                        
                        scene.rootNode.addChildNode(sphereNode)
                    }
                }
    }
    
    private func createPhysicsBoundaries() {
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        let floorNode = SCNNode(geometry: floor)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil) // type: .static で動かない物体に
        scene.rootNode.addChildNode(floorNode)
        
        let wallGeometry = SCNPlane(width: 100, height: 100)
        wallGeometry.firstMaterial?.isDoubleSided = true
        
        let leftWall = SCNNode(geometry: wallGeometry)
        leftWall.position = SCNVector3(-20, 0, 0)
        leftWall.eulerAngles = SCNVector3(0, CGFloat.pi / 2, 0) // Y軸で90度回転
        leftWall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(leftWall)
        
        let rightWall = SCNNode(geometry: wallGeometry)
        rightWall.position = SCNVector3(20, 0, 0)
        rightWall.eulerAngles = SCNVector3(0, -CGFloat.pi / 2, 0)
        rightWall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(rightWall)
    }
    
    private func createEmotionSphere(for emotion: SavedEmotion) {
        let sphere = SCNSphere(radius: 2.0)
        
        sphere.firstMaterial?.diffuse.contents = UIColor(hex: emotion.colorCode)
        
        let sphereNode = SCNNode(geometry: sphere)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphere, options: nil))
        physicsBody.mass = 1.0
        physicsBody.restitution = 0.5
        physicsBody.friction = 0.8
        sphereNode.physicsBody = physicsBody
        
        let randomX = Float.random(in: -10...10)
        sphereNode.position = SCNVector3(x: randomX, y: 30, z: 0)
        
        scene.rootNode.addChildNode(sphereNode)
    }
}
