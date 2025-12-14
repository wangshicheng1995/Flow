//
//  HighQualityProteinCard.swift
//  Flow
//
//  Created on 2025-12-14.
//

import SwiftUI

/// 首页优质蛋白卡片视图
/// 用于在 HomeView 的 LazyVGrid 中展示今日摄入的优质蛋白种类数量
struct HighQualityProteinCard: View {
    /// 优质蛋白种类数量（格式化后的字符串）
    let value: String
    /// 点击卡片时的回调
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和右上角图标
            HStack {
                Text("优质蛋白")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 数值和单位
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("种")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
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
        HighQualityProteinCard(value: "8")
        HighQualityProteinCard(value: "5")
    }
    .padding()
}
