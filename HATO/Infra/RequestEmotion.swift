//
//  RequestEmotion.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

import Foundation

struct EmotionRequest: Encodable {
    let title: String
    let artist: String
}

struct EmotionResponse: Decodable {
    let emotion: String
    let color: String
    
//    enum CodingKeys: String, CodingKey {
//        case emotion
//        case colorCode = "color_code"
//    }
}

class EmotionAPIClient {
    
    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case decodingError(Error)
    }
    
    func fetchEmotion(title: String, artist: String) async throws -> EmotionResponse {
        guard let url = URL(string: "https://hato-backend.onrender.com/process") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(EmotionRequest(title: title, artist: artist))
        print("\(try JSONEncoder().encode(EmotionRequest(title: title, artist: artist)))")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(EmotionResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
