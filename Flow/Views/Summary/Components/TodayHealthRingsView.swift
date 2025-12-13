//
//  TodayHealthRingsView.swift
//  Flow
//
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - 健康圆环数据模型
struct HealthRingData {
    let nutritionBalanceIndex: Double    // 营养均衡指数 (0-1)
    let dietQualityIndex: Double         // 饮食质量指数 (0-1)
    let daysCount: Int                   // 记录天数
    
    /// 综合健康百分比
    var overallPercentage: Int {
        Int((nutritionBalanceIndex + dietQualityIndex) / 2 * 100)
    }
}

// MARK: - 颜色常量（匹配设计稿）
private enum RingColors {
    static let nutritionBalance = Color(red: 139/255, green: 127/255, blue: 199/255)     // 紫色 #8B7FC7
    static let dietQuality = Color(red: 232/255, green: 166/255, blue: 104/255)          // 橙色 #E8A668
    static let nutritionBalanceBackground = Color(red: 139/255, green: 127/255, blue: 199/255).opacity(0.2)
    static let dietQualityBackground = Color(red: 232/255, green: 166/255, blue: 104/255).opacity(0.2)
    static let titleColor = Color(red: 30/255, green: 41/255, blue: 59/255)              // 深蓝黑色
}

// MARK: - 今日健康圆环视图
struct TodayHealthRingsView: View {
    let data: HealthRingData
    
    var body: some View {
        GlassCard {
            HStack(alignment: .center, spacing: 16) {
                // 左侧文案区域
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    Text("健康圆环")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(RingColors.titleColor)
                    
                    // 天数显示
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(data.daysCount)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(RingColors.titleColor)
                        
                        Text("天")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 图例
                    HStack(spacing: 8) {
                        LegendItem(color: RingColors.nutritionBalance, label: "营养均衡")
                        LegendItem(color: RingColors.dietQuality, label: "饮食质量")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 右侧双环进度图
                DoubleRingView(data: data)
                    .frame(width: 120, height: 120)
            }
            .padding(20)
        }
    }
}

// MARK: - 图例项
private struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(RingColors.titleColor)
        }
    }
}

// MARK: - 双环进度视图
private struct DoubleRingView: View {
    let data: HealthRingData
    
    private let outerRingWidth: CGFloat = 12
    private let innerRingWidth: CGFloat = 10
    private let ringGap: CGFloat = 6
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let outerRadius = (size - outerRingWidth) / 2
            let innerRadius = outerRadius - outerRingWidth / 2 - ringGap - innerRingWidth / 2
            
            ZStack {
                // 外圈背景（营养均衡指数）
                Circle()
                    .stroke(RingColors.nutritionBalanceBackground, lineWidth: outerRingWidth)
                    .frame(width: outerRadius * 2, height: outerRadius * 2)
                
                // 外圈进度（营养均衡指数）
                Circle()
                    .trim(from: 0, to: data.nutritionBalanceIndex)
                    .stroke(
                        RingColors.nutritionBalance,
                        style: StrokeStyle(lineWidth: outerRingWidth, lineCap: .round)
                    )
                    .frame(width: outerRadius * 2, height: outerRadius * 2)
                    .rotationEffect(.degrees(-90))
                
                // 内圈背景（饮食质量指数）
                Circle()
                    .stroke(RingColors.dietQualityBackground, lineWidth: innerRingWidth)
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                
                // 内圈进度（饮食质量指数）
                Circle()
                    .trim(from: 0, to: data.dietQualityIndex)
                    .stroke(
                        RingColors.dietQuality,
                        style: StrokeStyle(lineWidth: innerRingWidth, lineCap: .round)
                    )
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                    .rotationEffect(.degrees(-90))
                
                // 中心百分比
                Text("\(data.overallPercentage)%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(RingColors.titleColor)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

// MARK: - 玻璃卡片容器（Liquid Glass 风格）
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - 压力等级枚举（保留供其他组件使用）
enum StressLevel {
    case low       // 低压力 (0-40)
    case medium    // 中等压力 (40-70)
    case high      // 高压力 (70-100)
    
    var text: String {
        switch self {
        case .low: return "压力较低"
        case .medium: return "中等压力"
        case .high: return "压力偏高"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        }
    }
    
    static func from(score: Int) -> StressLevel {
        switch score {
        case 0..<40: return .low
        case 40..<70: return .medium
        default: return .high
        }
    }
}

// MARK: - Preview
#Preview("高完成度") {
    TodayHealthRingsView(
        data: HealthRingData(
            nutritionBalanceIndex: 0.92,
            dietQualityIndex: 0.76,
            daysCount: 48
        )
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("中等完成度") {
    TodayHealthRingsView(
        data: HealthRingData(
            nutritionBalanceIndex: 0.65,
            dietQualityIndex: 0.50,
            daysCount: 23
        )
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("低完成度") {
    TodayHealthRingsView(
        data: HealthRingData(
            nutritionBalanceIndex: 0.25,
            dietQualityIndex: 0.15,
            daysCount: 7
        )
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}
