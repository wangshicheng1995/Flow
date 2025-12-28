//
//  CalorieOverviewCard.swift
//  Flow
//
//  卡路里总览卡片组件
//  对接后端接口：/calories/daily
//

import SwiftUI

// MARK: - 卡路里总览卡片
struct CalorieOverviewCard: View {
    /// 柱状图数据（来自 SummaryService.fetchDailyCalories）
    var barData: [CGFloat] = [300, 450, 380, 520, 680, 420, 550] // 默认 mock 数据（7 天）
    
    /// 今日总卡路里
    var todayCalories: Int = 0
    
    /// 今日餐食数量
    var mealCount: Int = 0
    
    /// 是否正在加载
    var isLoading: Bool = false
    
    /// 点击回调
    var onTap: (() -> Void)?
    
    /// 状态文本（根据卡路里值动态显示）
    private var statusText: String {
        if todayCalories == 0 {
            return "暂无数据"
        } else if todayCalories < 1500 {
            return "偏低"
        } else if todayCalories <= 2200 {
            return "正常"
        } else {
            return "偏高"
        }
    }
    
    /// 状态颜色
    private var statusColor: Color {
        if todayCalories == 0 {
            return SummaryColors.textTertiary
        } else if todayCalories < 1500 {
            return SummaryColors.accentRed
        } else if todayCalories <= 2200 {
            return SummaryColors.accentGreen
        } else {
            return SummaryColors.accentRed
        }
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // 标题行
                HStack {
                    Text("卡路里总览")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(SummaryColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SummaryColors.textSecondary)
                }
                
                // 内容区域
                HStack(alignment: .bottom, spacing: 0) {
                    // 左侧：卡路里数值和状态
                    VStack(alignment: .leading, spacing: 8) {
                        if isLoading {
                            // 加载状态
                            ProgressView()
                                .frame(height: 36)
                        } else {
                            // 卡路里数值
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(todayCalories)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(SummaryColors.textPrimary)
                                
                                Text("千卡")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(SummaryColors.textTertiary)
                            }
                        }
                        
                        // 状态标签
                        HStack(spacing: 4) {
                            Text(statusText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(statusColor)
                            
                            // if mealCount > 0 {
                            //     Text("·")
                            //         .foregroundColor(SummaryColors.textTertiary)
                            //     Text("\(mealCount) 餐")
                            //         .font(.system(size: 14, weight: .regular))
                            //         .foregroundColor(SummaryColors.textTertiary)
                            // }
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧：柱状图（传入数据）
                    CalorieBarChart(barData: barData)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(SummaryColors.cardBgColor)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 卡路里柱状图
struct CalorieBarChart: View {
    /// 柱状图数据（外部传入，来自 SummaryService）
    var barData: [CGFloat]
    
    /// 柱状图最大高度
    private let maxBarHeight: CGFloat = 60
    
    /// 金黄色主色调 #FFD60A
    private let barColor = Color(red: 255/255, green: 214/255, blue: 10/255)
    
    /// 动态计算最高柱子的索引（基于数据，非 hardcode）
    private var maxIndex: Int {
        guard !barData.isEmpty else { return 0 }
        // 找到最大值的索引
        var maxIdx = 0
        var maxValue: CGFloat = barData[0]
        for (index, value) in barData.enumerated() {
            if value > maxValue {
                maxValue = value
                maxIdx = index
            }
        }
        return maxIdx
    }
    
    /// 归一化后的柱子高度（将数据转换为 0-1 范围）
    private var normalizedHeights: [CGFloat] {
        guard !barData.isEmpty else { return [] }
        let maxValue = barData.max() ?? 1
        guard maxValue > 0 else { return barData.map { _ in CGFloat(0) } }
        return barData.map { $0 / maxValue }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<barData.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        index == maxIndex
                            ? barColor // 最高的柱子用金黄色
                            : barColor.opacity(0.3) // 其他柱子用 30% 透明度
                    )
                    .frame(width: 12, height: maxBarHeight * normalizedHeights[index])
            }
        }
        .frame(height: maxBarHeight)
    }
}

// MARK: - Previews

// 真实 API 返回的数据（/api/summary/calories/daily）
// 日期: 12-20 到 12-26，今日（12-26）卡路里 1668，餐数 3
#Preview("真实数据") {
    CalorieOverviewCard(
        barData: [1646, 1412, 1433, 1683, 1699, 1298, 1668],
        todayCalories: 1668,
        mealCount: 3
    )
    .padding()
    .background(SummaryColors.bgColor)
}

#Preview("加载状态") {
    CalorieOverviewCard(
        isLoading: true
    )
    .padding()
    .background(SummaryColors.bgColor)
}

#Preview("暂无数据") {
    CalorieOverviewCard(
        barData: [],
        todayCalories: 0,
        mealCount: 0
    )
    .padding()
    .background(SummaryColors.bgColor)
}
