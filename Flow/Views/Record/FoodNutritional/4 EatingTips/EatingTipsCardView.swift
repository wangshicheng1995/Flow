//
//  EatingTipsCardView.swift
//  Flow
//
//  饮食建议卡片组件
//  从 FoodNutritionalView 中提取的独立组件
//
//  Created on 2025-12-28.
//

import SwiftUI

// MARK: - 饮食建议卡片视图

/// 饮食建议卡片组件
/// 展示调整进食顺序等饮食建议
struct EatingTipsCardView: View {
    // MARK: - 属性
    
    /// 饮食建议数据
    let data: EatingTipsData
    /// 是否可见（用于滑入动画）
    var isVisible: Bool = true
    /// 点击卡片时的回调
    var onTap: (() -> Void)?
    
    // MARK: - 设计稿颜色
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    private let healthyColor = Color(red: 29/255, green: 194/255, blue: 134/255)
    private let tipIconColor = Color(red: 255/255, green: 193/255, blue: 7/255)
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            headerSection
            
            // 建议列表
            tipsListSection
            
            // 预期效果
            if let improvement = data.expectedImprovement {
                improvementSection(improvement: improvement)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
    
    // MARK: - 标题区域
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(tipIconColor)
            
            Text("怎么吃血糖更平稳")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(textPrimary)
            
            Spacer()
        }
    }
    
    // MARK: - 建议列表
    
    private var tipsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data.tips) { tip in
                tipRow(tip: tip)
            }
        }
    }
    
    /// 单条建议行
    private func tipRow(tip: EatingTip) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 序号圆圈 - 使用固定宽度确保垂直对齐
            ZStack {
                Circle()
                    .fill(healthyColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text("\(tip.order)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(healthyColor)
            }
            .frame(width: 28) // 固定宽度确保对齐
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textPrimary)
                
                Text(tip.description)
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - 预期效果
    
    private func improvementSection(improvement: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.right.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(healthyColor)
            
            Text(improvement)
                .font(.system(size: 12))
                .foregroundColor(healthyColor)
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview

#Preview("饮食建议卡片") {
    VStack(spacing: 16) {
        EatingTipsCardView(
            data: EatingTipsData(
                title: "调整进食顺序可降低血糖峰值",
                tips: [
                    EatingTip(order: 1, iconName: "leaf.fill", title: "先吃蔬菜",
                             description: "膳食纤维可减缓碳水吸收，建议先吃蔬菜类食物",
                             relatedFoods: ["炒菠菜"]),
                    EatingTip(order: 2, iconName: "fish.fill", title: "再吃蛋白质",
                             description: "蛋白质可延长饱腹感，稳定血糖水平",
                             relatedFoods: ["卤肉", "香肠"]),
                    EatingTip(order: 3, iconName: "fork.knife", title: "最后吃主食",
                             description: "将碳水化合物放在最后，可显著降低血糖峰值",
                             relatedFoods: ["饺子", "米饭"])
                ],
                expectedImprovement: "按建议调整后，血糖峰值预计可降低 15-20%"
            )
        )
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}
