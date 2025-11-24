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
    @StateObject private var authManager = AuthenticationManager.shared
    
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
            // 检查调试开关和认证状态
            if AuthenticationManager.isAppleLoginEnabled && !authManager.isAuthenticated {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
