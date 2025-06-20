//
//  SavedEmotion.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

import Foundation
import SwiftData

@Model
final class SavedEmotion {
    @Attribute(.unique) var id: String
    
    var emotion: String
    var colorCode: String
    var modelFileName: String
    var sourceTitle: String
    var sourceArtist: String
    var timestamp: Date
    
    init(emotion: String, colorCode: String, modelFileName: String, sourceTitle: String, sourceArtist: String, timestamp: Date) {
        self.id = UUID().uuidString
        self.emotion = emotion
        self.colorCode = colorCode
        self.modelFileName = modelFileName
        self.sourceTitle = sourceTitle
        self.sourceArtist = sourceArtist
        self.timestamp = timestamp
    }
}
