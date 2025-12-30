//
//  OverallCardView.swift
//  Flow
//
//  总览卡片组件 - 显示本餐卡路里和营养素信息
//  从 FoodNutritionalView 中提取
//
//  Created on 2025-12-28.
//

import SwiftUI

// MARK: - 总览卡片视图

/// 总览卡片组件
/// 展示本餐卡路里、用户上传图片、以及三大营养素（碳水、蛋白质、脂肪）
struct OverallCardView: View {
    // MARK: - 属性
    
    /// 卡路里数值
    let calories: Int?
    /// 碳水化合物（克）
    let carbs: Double
    /// 蛋白质（克）
    let proteins: Double
    /// 脂肪（克）
    let fats: Double
    /// 用户上传的食物图片
    var capturedImage: UIImage?
    
    // MARK: - 设计稿颜色
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    /// 碳水化合物颜色（黄色）
    private let carbsColor = Color(red: 255/255, green: 193/255, blue: 7/255)
    /// 蛋白质颜色（绿色）
    private let proteinColor = Color(red: 76/255, green: 175/255, blue: 80/255)
    /// 脂肪颜色（蓝色）
    private let fatColor = Color(red: 33/255, green: 150/255, blue: 243/255)
    
    // MARK: - 计算属性
    
    private var calorieText: String {
        guard let calories = calories else { return "--" }
        return "\(calories)"
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题和卡路里区域
            calorieSection
            
            // 营养素展示区域：碳水化合物、蛋白质、脂肪
            nutrientsSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - 卡路里区域
    
    private var calorieSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 「本餐卡路里：」标签
            Text("本餐卡路里：")
                .font(.system(size: 12, weight: .regular))
                .tracking(0.12)
                .foregroundColor(textSecondary)
                .padding(.vertical, 8)
            
            // 卡路里值 + 用户上传图片
            HStack {
                // 主数字：48px bold，视觉焦点
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(calorieText)
                        .font(.system(size: 48, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(textPrimary)
                    
                    Text("千卡")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(textTertiary)
                        .offset(y: -5)
                }
                
                Spacer()
                
                // 用户上传的图片 40x40（靠右对齐）
                foodImageView
            }
        }
    }
    
    // MARK: - 食物图片
    
    private var foodImageView: some View {
        Group {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            } else {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(textPrimary.opacity(0.5))
                    )
            }
        }
    }
    
    // MARK: - 营养素区域
    
    private var nutrientsSection: some View {
        HStack(spacing: 77) {
            // 碳水化合物 - 黄色
            NutrientColumn(
                label: "碳水",
                value: Int(carbs),
                color: carbsColor
            )
            
            // 蛋白质 - 绿色
            NutrientColumn(
                label: "蛋白质",
                value: Int(proteins),
                color: proteinColor
            )
            
            // 脂肪 - 蓝色
            NutrientColumn(
                label: "脂肪",
                value: Int(fats),
                color: fatColor
            )
        }
        .padding(.top, 1)
        .padding(.leading, 4)
    }
}

// MARK: - 营养素列组件

/// 展示单个营养素的标签和数值
struct NutrientColumn: View {
    let label: String
    let value: Int
    let color: Color
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 彩色圆点 + 标签
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textTertiary)
            }
            
            // 数值 + 单位
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                Text("g")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(textTertiary)
            }
        }
    }
}

// MARK: - Preview

#Preview("总览卡片") {
    VStack(spacing: 16) {
        OverallCardView(
            calories: 650,
            carbs: 35,
            proteins: 43,
            fats: 36
        )
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}

#Preview("总览卡片 - 无数据") {
    VStack(spacing: 16) {
        OverallCardView(
            calories: nil,
            carbs: 0,
            proteins: 0,
            fats: 0
        )
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}
