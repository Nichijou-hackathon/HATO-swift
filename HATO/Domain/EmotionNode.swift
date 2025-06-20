//
//  EmotionNode.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/21.
//

import SceneKit
import SwiftData

class EmotionNode: SCNNode {
    let emotionData: SavedEmotion

    init(emotion: SavedEmotion) {
        self.emotionData = emotion
        super.init()
        guard let modelScene = SCNScene(named: emotion.modelFileName) else {
            print("モデルの読み込みに失敗: \(emotion.modelFileName)")
            self.geometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
            self.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            return
        }
        
        let wrapperNode = SCNNode()
        for childNode in modelScene.rootNode.childNodes {
            wrapperNode.addChildNode(childNode)
        }
        self.addChildNode(wrapperNode)
        
        let scale: Float = 4.0
        self.scale = SCNVector3(scale, scale, scale)
        
        let color = UIColor(hex: emotion.colorCode)
        self.enumerateChildNodes { (node, _) in
            node.geometry?.materials.forEach { $0.diffuse.contents = color }
        }
    
        let physicsShape = SCNPhysicsShape(node: wrapperNode, options: [.type: SCNPhysicsShape.ShapeType.boundingBox])
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.mass = 1.0
        physicsBody.restitution = 1.0
        physicsBody.friction = 0.8
        self.physicsBody = physicsBody
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
