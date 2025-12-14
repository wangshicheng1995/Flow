//
//  HealthJourneyPromoCard.swift
//  Flow
//
//  Created on 2025-12-14.
//

import SwiftUI

/// 首页「开启你的健康之旅」推广卡片视图
/// 用于在 HomeView 的 LazyVGrid 中展示引导用户开始健康记录的推广信息
struct HealthJourneyPromoCard: View {
    /// 点击卡片时的回调
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text("开启你的\n健康之旅")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            Spacer()
            
            // 右下角箭头图标
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(height: 150)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        HealthJourneyPromoCard()
        HealthJourneyPromoCard()
    }
    .padding()
}
