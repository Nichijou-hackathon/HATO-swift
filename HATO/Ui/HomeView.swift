//
//  HomeView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("見つける", systemImage: "music.note.list")
                }
            PhysicsHomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
            SavedEmotionListsView()
                .tabItem {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}


