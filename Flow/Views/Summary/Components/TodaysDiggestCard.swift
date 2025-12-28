//
//  TodaysDiggestCard.swift
//  Flow
//
//  今日建议卡片组件
//

import SwiftUI

// MARK: - Today's Diggest 卡片
struct TodaysDiggestCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("TODAY'S DIGGEST")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.0)
                .foregroundColor(SummaryColors.textTertiary)
            
            // 主标题
            Text("Keep your next meal light and filling")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(SummaryColors.textPrimary)
            
            // 描述文本
            Text("You're at 67% of your calories, macros look good—carbs are a bit low.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(SummaryColors.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(SummaryColors.cardBgColor)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    TodaysDiggestCard()
        .padding()
        .background(SummaryColors.bgColor)
}
