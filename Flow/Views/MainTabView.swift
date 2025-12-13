//
//  MainTabView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI
import UIKit

// MARK: - Tab 选择枚举
enum AppTab: Int, Hashable {
    case today = 0
    case summary = 1
    case camera = 2
    case history = 3
}

// MARK: - 主导航容器视图
struct MainTabView: View {
    @State private var selectedTab: AppTab = .today
    @StateObject private var stressScoreViewModel = StressScoreViewModel()
    @StateObject private var homeDataViewModel = HomeDataViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.today) {
                HomeView()
                    .environment(\.selectedTab, $selectedTab)
                    .environmentObject(homeDataViewModel)
            } label: {
                Label("Flow", systemImage: "sun.max")
            }

            Tab(value: AppTab.summary) {
                SummaryView()
            } label: {
                Label("摘要", systemImage: "chart.bar.doc.horizontal")
            }

            Tab(value: AppTab.camera) {
                CameraView()
                    .environment(\.selectedTab, $selectedTab)
                    .environmentObject(stressScoreViewModel)
            } label: {
                Label("拍照", systemImage: "camera")
            }

            Tab(value: AppTab.history) {
                MyView()
            } label: {
                Label("我的", systemImage: "person")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

// MARK: - 环境值：Tab 选择
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<AppTab> = .constant(.today)
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
