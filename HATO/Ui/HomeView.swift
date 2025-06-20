//
//  HomeView.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/20.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 1
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Songs", systemImage: "music.note.list")
                }
                .tag(0)
            PhysicsHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            SavedEmotionListsView()
                .tabItem {
                    Label("HeArt", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
    }
}


