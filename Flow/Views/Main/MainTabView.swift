//
//  MainTabView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - Tab 选择枚举
enum AppTab: Int, Hashable {
    case photo = 0
    case analysis = 1
    case history = 2
}

// MARK: - 主导航容器视图
struct MainTabView: View {
    @State private var selectedTab: AppTab = .photo

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("拍照", systemImage: "camera")
                }
                .tag(AppTab.photo)
                .environment(\.selectedTab, $selectedTab)

            AnalysisTabView()
                .tabItem {
                    Label("分析", systemImage: "chart.bar.doc.horizontal")
                }
                .tag(AppTab.analysis)

            SummaryView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(AppTab.history)
        }
    }
}

// MARK: - 环境值：Tab 选择
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<AppTab> = .constant(.photo)
}

extension EnvironmentValues {
    var selectedTab: Binding<AppTab> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .modelContainer(for: [FoodRecord.self], inMemory: true)
}
