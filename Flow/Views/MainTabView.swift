//
//  MainTabView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - 主导航容器视图
struct MainTabView: View {
    var body: some View {
        TabView {
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.doc.horizontal")
                }

            HomeView()
                .tabItem {
                    Label("Photo", systemImage: "camera")
                }

            AnalysisHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .modelContainer(for: [FoodRecord.self], inMemory: true)
}
