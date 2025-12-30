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
    @AppStorage(ThemePreference.storageKey) private var storedThemePreference = ThemePreference.system.rawValue
    
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

    private var themePreference: ThemePreference {
        ThemePreference.resolve(storedThemePreference)
    }

    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    // Splash 结束后，根据状态路由
                    if authManager.isAuthenticated {
                        if authManager.hasCompletedOnboarding {
                            MainTabView()
                        } else {
                            // 已登录但未完成资料填写
                            OnboardingContainerView()
                        }
                    } else {
                        // 未登录 -> 进入登录/开始页
                        GetStartedView()
                    }
                }
            }
            .preferredColorScheme(themePreference.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
