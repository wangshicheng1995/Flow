//
//  FlowApp.swift
//  Flow
//
//  Created by Echo Wang on 2025/11/5.
//

import SwiftUI
import SwiftData

@main
struct FlowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            FoodRecord.self,
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
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
