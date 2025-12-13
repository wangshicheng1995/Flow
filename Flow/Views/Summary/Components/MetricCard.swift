//
//  MetricCard.swift
//  Flow
//
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - 指标状态枚举
enum MetricStatus: Equatable {
    case normal       // 正常（绿色）
    case nearGoal     // 接近目标（绿色）
    case slightlyLow  // 略偏低（黄色）
    case slightlyHigh // 略偏高（黄色）
    case high         // 偏高（橙色）
    case low          // 过低（橙色）
    case warning      // 需要注意（红色）
    
    var text: String {
        switch self {
        case .normal: return "正常"
        case .nearGoal: return "接近目标"
        case .slightlyLow: return "略偏低"
        case .slightlyHigh: return "略偏高"
        case .high: return "偏高"
        case .low: return "过低"
        case .warning: return "需要注意"
        }
    }
    
    var color: Color {
        switch self {
        case .normal, .nearGoal:
            return .green
        case .slightlyLow, .slightlyHigh:
            return .yellow
        case .high, .low:
            return .orange
        case .warning:
            return .red
        }
    }
    
    var backgroundColor: Color {
        color.opacity(0.15)
    }
}

// MARK: - 核心指标卡片
struct MetricCard: View {
    let title: String
    let status: MetricStatus
    let valueText: String
    let subText: String
    let hint: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部：标题 + 状态标签
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                StatusTag(status: status)
            }
            
            // 中部：主数值
            VStack(alignment: .leading, spacing: 4) {
                Text(valueText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(subText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 4)
            
            // 底部：建议文案
            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 160)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

// MARK: - 状态标签
struct StatusTag: View {
    let status: MetricStatus
    
    var body: some View {
        Text(status.text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
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
        .padding(16)
    }
    .background(Color(.systemGroupedBackground))
}
