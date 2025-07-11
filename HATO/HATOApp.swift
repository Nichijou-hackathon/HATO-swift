//
//  HATOApp.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/17.
//

import SwiftUI
import SwiftData

@main
struct HATOApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedEmotion.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
