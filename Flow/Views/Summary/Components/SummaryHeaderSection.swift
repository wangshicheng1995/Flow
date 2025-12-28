//
//  SummaryHeaderSection.swift
//  Flow
//
//  顶部标题区域组件
//

import SwiftUI

// MARK: - 顶部标题区域
struct SummaryHeaderSection: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overview")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(SummaryColors.textPrimary)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(SummaryColors.accentBlue)
                        .frame(width: 8, height: 8)
                    
                    Text("126 DATA")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(SummaryColors.textSecondary)
                }
            }
            
            Spacer()
            
            // 牛油果图标（使用 emoji）
            Text("🥑")
                .font(.system(size: 40))
                .frame(width: 44, height: 44)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SummaryHeaderSection()
        .padding()
        .background(SummaryColors.bgColor)
}
