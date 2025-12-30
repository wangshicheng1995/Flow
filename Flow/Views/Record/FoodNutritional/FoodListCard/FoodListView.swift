//
//  FoodListView.swift
//  Flow
//
//  食物列表组件 - 显示热量明细列表
//  从 FoodNutritionalView 中提取
//
//  Created on 2025-12-28.
//

import SwiftUI

// MARK: - 食物列表视图

/// 食物列表组件
/// 展示热量明细标题和食物列表
struct FoodListView: View {
    // MARK: - 属性
    
    /// 食物数据列表
    let foods: [FoodItem]?
    
    // MARK: - 设计稿颜色
    
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    private let shadowColor = Color(red: 201/255, green: 201/255, blue: 201/255)
    
    // 食材热量等级颜色
    private let highCalorieColor = Color(red: 239/255, green: 83/255, blue: 80/255)   // 红色（过高）
    private let normalCalorieColor = Color(red: 100/255, green: 181/255, blue: 246/255) // 蓝色（正常）
    private let healthyCalorieColor = Color(red: 29/255, green: 194/255, blue: 134/255) // 绿色（健康）
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // 热量明细标题
            foodListHeader
            
            // 食物列表
            foodListItems
        }
    }
    
    // MARK: - 热量明细标题
    
    private var foodListHeader: some View {
        Text("热量明细")
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(textSecondary)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .overlay(Capsule().stroke(Color.white, lineWidth: 1))
            )
            .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
    }
    
    // MARK: - 食物列表
    
    private var foodListItems: some View {
        let foodCount = foods?.count ?? 0
        let spacing: CGFloat = foodCount < 6 ? 7 : 6
        
        // 分析非蛋白热量，获取每个食材的等级
        let calorieLevels = foods != nil
            ? NonProteinCalorieAnalyzer.analyze(foods: foods!)
            : [:]
        
        return VStack(spacing: spacing) {
            if let foods = foods {
                ForEach(foods, id: \.name) { food in
                    // 根据分析结果决定图标颜色
                    let level = calorieLevels[food.name] ?? .normal
                    let iconColor: Color = {
                        switch level {
                        case .high:    return highCalorieColor
                        case .normal:  return normalCalorieColor
                        case .healthy: return healthyCalorieColor
                        }
                    }()
                    
                    FoodRowView(
                        iconGradientColor: iconColor,
                        name: food.name,
                        cook: food.cook ?? "",
                        kcal: food.kcal,
                        carbs: food.carbs ?? 0,
                        proteins: food.proteins ?? 0,
                        fats: food.fats ?? 0
                    )
                }
            } else {
                // 无数据时显示占位
                Text("暂无食物数据")
                    .font(.system(size: 14))
                    .foregroundColor(textTertiary)
                    .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - 食材行组件

/// 单个食材行视图
struct FoodRowView: View {
    let iconGradientColor: Color
    let name: String
    let cook: String
    let kcal: Int
    let carbs: Double
    let proteins: Double
    let fats: Double
    
    /// 根据食物名称匹配的图标名称
    private var iconName: String {
        FoodIconMapper.getIconName(for: name)
    }
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    var body: some View {
        HStack(spacing: 0) {
            // 食物图标 36x36
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconGradientColor.opacity(0.15),
                                iconGradientColor.opacity(0.08),
                                iconGradientColor.opacity(0.02)
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .frame(width: 36, height: 36)
                
                // 使用匹配的食物图标
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(iconGradientColor)
                    .frame(width: 20, height: 20)
            }
            
            // 食物名称和营养信息
            VStack(alignment: .leading, spacing: 8) {
                // 食物名称
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.07)
                    .foregroundColor(textPrimary)
                
                // 营养信息：碳水 • 蛋白 • 脂肪
                HStack(spacing: 0) {
                    Text("碳水 \(Int(carbs))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    Text(" 蛋白质 \(Int(proteins))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    Text(" 脂肪 \(Int(fats))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                }
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // 卡路里：数字 + 单位
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(kcal)")
                    .font(.system(size: 16, weight: .medium))
                    .tracking(-0.08)
                    .foregroundColor(textPrimary)
                
                Text("千卡")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textTertiary)
            }
            .padding(.trailing, 12)
        }
        .padding(.leading, 22)
        .padding(.trailing, 16)
        .frame(height: 68)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview("食物列表") {
    VStack(spacing: 16) {
        FoodListView(
            foods: [
                FoodItem(name: "饺子", cook: "水煮", kcal: 350, carbs: 60, proteins: 12, fats: 4),
                FoodItem(name: "香肠", cook: "蒸煮", kcal: 280, carbs: 1, proteins: 14, fats: 22),
                FoodItem(name: "卤肉", cook: "卤制", kcal: 220, carbs: 2, proteins: 20, fats: 12),
                FoodItem(name: "炒菠菜", cook: "清炒", kcal: 50, carbs: 7, proteins: 4, fats: 1)
            ]
        )
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}

#Preview("食物列表 - 无数据") {
    VStack(spacing: 16) {
        FoodListView(foods: nil)
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}
