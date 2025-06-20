//
//  EmotionModelConverter.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//


struct EmotionModelConverter {
    let prefix: String

    init(prefix: String = "HATO_") {
        self.prefix = prefix
    }

    func modelFileName(for emotion: String) -> String {
        return "\(prefix)\(emotion.capitalized).usdz"
    }
}
