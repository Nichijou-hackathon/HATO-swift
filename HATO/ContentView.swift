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

    var body: some View {
        NavigationView {
            VStack {
                switch requestState {
                case .loading:
                    ProgressView()
                case .success:
                    if recentSongs.isEmpty {
                        Text("再生履歴がありません。")
                            .foregroundColor(.secondary)
                    } else {
                        List(recentSongs) { song in
                            MusicItemRow(song: song)
                        }
                    }
                case .failed(let error):
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("エラーが発生しました")
                            .padding(.top, 4)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
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
        } catch {
            await MainActor.run {
                self.requestState = .failed(error)
                print("再生履歴の取得に失敗しました: \(error)")
            }
        }
    }
}

/// 読み込み状態を管理するための列挙型
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

#Preview {
    ContentView()
}
