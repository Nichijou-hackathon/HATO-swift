//
//  ContentView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/17.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    
    @State private var recentSongs: [Song] = []
    @State private var requestState: RequestState = .loading
    @State private var latestSongEmotion: EmotionResponse?
    
    private let apiClient = EmotionAPIClient()
    
    var body: some View {
        NavigationView {
            VStack {
                switch requestState {
                case .loading:
                    ProgressView("再生履歴を取得中...")
                    
                case .success:
                    if let emotion = latestSongEmotion, let song = recentSongs.first {
                        LatestSongEmotionView(song: song, emotionData: emotion)
                            .padding([.horizontal, .top])
                    }
                    
                    if recentSongs.isEmpty {
                        Spacer()
                        Text("再生履歴がありません。")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List(recentSongs) { song in
                            MusicItemRow(song: song)
                        }
                        .listStyle(.plain)
                    }
                    
                case .failed(let error):
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("エラーが発生しました")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .navigationTitle("最近再生した曲")
            .task {
                await fetchRecentlyPlayedMusic()
            }
        }
    }
    
    
    
    private func fetchRecentlyPlayedMusic() async {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            let error = NSError(domain: "MusicKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Musicへのアクセスが許可されていません。"])
            self.requestState = .failed(error)
            return
        }
        
        do {
            guard let url = URL(string: "https://api.music.apple.com/v1/me/recent/played/tracks?limit=30") else {
                return
            }
            let urlRequest = URLRequest(url: url)
            let dataRequest = MusicDataRequest(urlRequest: urlRequest)
            
            let dataResponse = try await dataRequest.response()
            
            let decoder = JSONDecoder()
            let songCollection = try decoder.decode(MusicItemCollection<Song>.self, from: dataResponse.data)
            
            await MainActor.run {
                self.recentSongs = Array(songCollection)
                self.requestState = .success
            }
            
            if let latestSong = songCollection.first {
                do {
                    let emotionResponse = try await apiClient.fetchEmotion(
                        title: latestSong.title,
                        artist: latestSong.artistName
                    )
                    print("\(latestSong.title)")
                    print("\(latestSong.artistName)")
                    await MainActor.run {
                        self.latestSongEmotion = emotionResponse
                    }
                } catch {
                    print("感情分析APIのエラー: \(error)")
                }
            }
        } catch {
            await MainActor.run {
                self.requestState = .failed(error)
                print("再生履歴の取得に失敗しました: \(error)")
            }
        }
    }
}


enum RequestState {
    case loading
    case success
    case failed(Error)
}


struct MusicItemRow: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 12) {
            if let artwork = song.artwork {
                AsyncImage(url: artwork.url(width: 60, height: 60)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.3))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(4)
                .shadow(radius: 2)
            }
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text(song.artistName)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LatestSongEmotionView: View {
    let song: Song
    let emotionData: EmotionResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最新の曲の感情分析")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                MusicItemRow(song: song)
                Spacer()
                VStack {
                    Text(emotionData.emotion.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: emotionData.color))
                    Text("Emotion")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(.clear)
            return
        }
        
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}



#Preview {
    ContentView()
}
