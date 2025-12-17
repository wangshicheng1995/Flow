//
//  SummaryView.swift
//  Flow
//
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - Summary 主视图
struct SummaryView: View {
    @State private var isShowingHistory = false
    @State private var isShowingMyView = false
    
    // MARK: - Mock 数据
    private let mockHealthRingData = HealthRingData(
        nutritionBalanceIndex: 0.92,
        dietQualityIndex: 0.76,
        daysCount: 48
    )
    
    private let mockTips = [
        "晚餐的油盐偏多，明天可以尝试少油少盐烹饪。",
        "蛋白质略低，适合在加餐中补一点酸奶或坚果。",
        "今天的总体热量已经接近目标，建议避免睡前进食。"
    ]
    
    private let mockHistoryItems: [HistoryItem] = [
        .init(date: "12/04", score: 58),
        .init(date: "12/05", score: 64),
        .init(date: "12/06", score: 60),
        .init(date: "12/07", score: 72),
        .init(date: "12/08", score: 45),
        .init(date: "12/09", score: 55)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: - 区域 1：今日健康圆环
                    TodayHealthRingsView(data: mockHealthRingData)
                        .padding(.horizontal, 16)
                    
                    
                    // MARK: - 区域 2：核心指标网格
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        MetricCard(
                            title: "总热量",
                            status: .nearGoal,
                            valueText: "1,780 kcal",
                            subText: "目标 2,000 kcal",
                            hint: "晚上注意避免额外零食，今天的总热量已经接近目标。"
                        )
                        
                        MetricCard(
                            title: "优质蛋白",
                            status: .slightlyLow,
                            valueText: "58 g",
                            subText: "建议 70–90 g",
                            hint: "今天可以再补充一点鱼类、鸡胸肉或豆制品。"
                        )
                        
                        MetricCard(
                            title: "糖压力",
                            status: .high,
                            valueText: "GL 78",
                            subText: "建议控制在 60 以下",
                            hint: "精制碳水略多，明天可尝试用全谷物或蔬菜替代部分主食。"
                        )
                        
                        MetricCard(
                            title: "盐压力",
                            status: .normal,
                            valueText: "2,900 mg",
                            subText: "建议 < 4,800 mg",
                            hint: "今天的钠摄入在合理范围内，可以继续保持当前口味。"
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - 区域 3：今日重点提醒
                    TodayTipsCard(tips: mockTips)
                        .padding(.horizontal, 16)
                    
                    // MARK: - 区域 4：过去记录入口
                    HistoryPreviewSection(
                        items: mockHistoryItems,
                        onViewAll: {
                            isShowingHistory = true
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("健康总览")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $isShowingHistory) {
                HistoryDetailView()
            }
            .navigationDestination(isPresented: $isShowingMyView) {
                MyView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingMyView = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - 历史详情页面占位符
struct HistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("历史记录详情")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("此页面将显示更详细的历史趋势数据和图表分析。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // 占位符内容
                ForEach(0..<10) { index in
                    HStack {
                        Text("12/0\(index + 1)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int.random(in: 40...80)) 分")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("历史记录")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    SummaryView()
}
