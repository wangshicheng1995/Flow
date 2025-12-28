//
//  SummaryView.swift
//  Flow
//
//  根据设计稿 1:1 复刻的健康概览页面
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - Summary 主视图
struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    @State private var isShowingHistory = false
    @State private var isShowingMyView = false
    
    // Preview 专用：预设数据
    private var previewBarData: [CGFloat]?
    private var previewTodayCalories: Int?
    private var previewMealCount: Int?
    
    /// 默认初始化器（使用 ViewModel 数据）
    init() {
        self.previewBarData = nil
        self.previewTodayCalories = nil
        self.previewMealCount = nil
    }
    
    /// Preview 专用初始化器（使用预设数据）
    init(previewBarData: [CGFloat], previewTodayCalories: Int, previewMealCount: Int) {
        self.previewBarData = previewBarData
        self.previewTodayCalories = previewTodayCalories
        self.previewMealCount = previewMealCount
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // MARK: - 顶部标题区域
                SummaryHeaderSection()
                
                // MARK: - 卡路里总览卡片（对接后端数据）
                CalorieOverviewCard(
                    barData: previewBarData ?? (viewModel.barChartData.isEmpty
                        ? [1646, 1412, 1433, 1683, 1699, 1298, 1668] // 默认 mock 数据
                        : viewModel.barChartData),
                    todayCalories: previewTodayCalories ?? viewModel.todayCalories,
                    mealCount: previewMealCount ?? viewModel.todayMealCount,
                    isLoading: previewBarData == nil && viewModel.isLoading
                )
                
                // MARK: - Stress Score 卡片
                StressScoreCard()
                
                // MARK: - 指标网格（4个小卡片）
                metricsGrid
                
                // MARK: - Today's Diggest 卡片
                TodaysDiggestCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100) // 为底部 TabBar 留出空间
        }
        .background(SummaryColors.bgColor)
        .task {
            // 页面加载时获取数据（仅在非 Preview 模式）
            if previewBarData == nil && !viewModel.hasLoadedOnce {
                await viewModel.loadAllData()
            }
        }
        .refreshable {
            // 下拉刷新
            await viewModel.loadAllData()
        }
    }
    
    // MARK: - 指标网格
    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            // Current Weight
            MetricSmallCard(
                title: "Current Weight",
                value: "200g",
                unit: "lbs",
                changePercent: 10,
                isPositive: true
            )
            
            // Active Minutes
            MetricSmallCard(
                title: "Active Minutes",
                value: "294",
                unit: "mins",
                changePercent: 10,
                isPositive: false
            )
            
            // Last Heart Rate
            MetricSmallCard(
                title: "Last Heart Rate",
                value: "82",
                unit: "bpm",
                changePercent: 10,
                isPositive: true
            )
            
            // Last HRV
            MetricSmallCard(
                title: "Last HRV",
                value: "56",
                unit: "ms",
                changePercent: 10,
                isPositive: false
            )
        }
    }
}

// MARK: - Previews

// 使用真实 API 返回的数据
#Preview("真实数据") {
    SummaryView(
        previewBarData: [1646, 1412, 1433, 1683, 1699, 1298, 1668],
        previewTodayCalories: 1668,
        previewMealCount: 3
    )
}

#Preview("默认") {
    SummaryView()
}
