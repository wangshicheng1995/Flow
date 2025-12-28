//
//  MetricSmallCard.swift
//  Flow
//
//  小型指标卡片组件
//

import SwiftUI

// MARK: - 小型指标卡片组件
struct MetricSmallCard: View {
    let title: String
    let value: String
    let unit: String
    let changePercent: Int
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(SummaryColors.textSecondary)
            
            // 值和变化百分比
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                // 主要值
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(SummaryColors.textPrimary)
                
                // 单位
                Text(unit)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(SummaryColors.textTertiary)
                
                Spacer()
                
                // 变化百分比
                HStack(spacing: 2) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                    
                    Text("\(changePercent)%")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(isPositive ? SummaryColors.accentGreen : SummaryColors.accentRed)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SummaryColors.cardBgColor)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ],
        spacing: 12
    ) {
        MetricSmallCard(
            title: "Current Weight",
            value: "200g",
            unit: "lbs",
            changePercent: 10,
            isPositive: true
        )
        
        MetricSmallCard(
            title: "Active Minutes",
            value: "294",
            unit: "mins",
            changePercent: 10,
            isPositive: false
        )
    }
    .padding()
    .background(SummaryColors.bgColor)
}
