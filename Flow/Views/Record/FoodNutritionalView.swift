//
//  FoodNutritionalView.swift
//  Flow
//
//  基于 Figma 设计稿分模块精确还原
//  设计稿节点: 43-3059 / 43-3106
//  使用 MCP 获取的精确样式参数
//

import SwiftUI

// MARK: - 主视图
struct FoodNutritionalView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// 食物分析数据
    var analysisData: FoodAnalysisData?
    
    /// 拍摄的食物图片
    var capturedImage: UIImage?
    
    // MARK: - 计算属性
    
    /// 食物名称（从 analysisData.foodName 读取）
    private var foodName: String {
        analysisData?.foodName ?? "分析结果"
    }
    
    /// 卡路里文本（不带单位）
    private var calorieText: String {
        guard let energyKcal = analysisData?.nutrition.energyKcal else {
            return "--"
        }
        return "\(energyKcal)"
    }
    
    // MARK: - 设计稿精确颜色
    private let bgColor = Color(red: 237/255, green: 237/255, blue: 237/255) // #ededed
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255) // #151515
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255) // #4d4d4d
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255) // #999
    private let shadowColor = Color(red: 201/255, green: 201/255, blue: 201/255) // rgba(201,201,201,0.1)
    
    // MARK: - 食材热量等级颜色（参考图二）
    private let highCalorieColor = Color(red: 239/255, green: 83/255, blue: 80/255)   // #EF5350 红色（过高）
    private let normalCalorieColor = Color(red: 100/255, green: 181/255, blue: 246/255) // #64B5F6 蓝色（正常）
    private let healthyCalorieColor = Color(red: 29/255, green: 194/255, blue: 134/255) // #1DC286 绿色（健康）
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                headerView
                    .padding(.top, 16)
                
                // 主内容（43:3106）
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 总览卡片 (43:3109)
                        overallCard
                        
                        // 食物清单标题 (43:3152)
                        foodListHeader
                        
                        // 食物清单列表 (43:3160)
                        foodListItems
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    private var headerView: some View {
        HStack {
            // 左侧返回按钮 48x48
            Button(action: { dismiss() }) {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(textPrimary)
                    )
                    .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
            }
            
            Spacer()
            
            // 中间食物名称胶囊
            HStack(spacing: 6) {
                Circle()
                    .fill(healthyCalorieColor)
                    .frame(width: 8, height: 8)
                Text(foodName)
                    .font(.system(size: 12, weight: .regular))
                    .tracking(0.12)
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .overlay(Capsule().stroke(Color.white, lineWidth: 1))
            )
            
            Spacer()
            
            // 右侧占位（保持布局平衡）
            Color.clear
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, 22)
    }
    
    // MARK: - 总览卡片 (43:3109)
    // backdrop-blur-[3px], bg-[rgba(255,255,255,0.5)], border-white
    // rounded-[36px], shadow-[0px_4px_6px_0px_rgba(201,201,201,0.1)]
    // pb-[24px] pt-[20px] px-[24px], gap-[20px]
    private var overallCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题和卡路里区域 (43:3110)
            VStack(alignment: .leading, spacing: 0) {
                // 「卡路里：」12px, #4d4d4d, tracking 0.12px
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
            
            // 营养素展示区域：碳水化合物、蛋白质、脂肪
            // 💡 调整 spacing 值可改变三列间距
            HStack(spacing: 77) {
                // 碳水化合物 - 黄色
                NutrientColumn(
                    label: "碳水",
                    value: Int(analysisData?.nutrition.carbG ?? 0),
                    color: Color(red: 255/255, green: 193/255, blue: 7/255) // 黄色
                )
                
                // 蛋白质 - 绿色
                NutrientColumn(
                    label: "蛋白质",
                    value: Int(analysisData?.nutrition.proteinG ?? 0),
                    color: Color(red: 76/255, green: 175/255, blue: 80/255) // 绿色
                )
                
                // 脂肪 - 蓝色
                NutrientColumn(
                    label: "脂肪",
                    value: Int(analysisData?.nutrition.fatG ?? 0),
                    color: Color(red: 33/255, green: 150/255, blue: 243/255) // 蓝色
                )
            }
            .padding(.top, 1)
            .padding(.leading, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.white.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 36)
                        .fill(.ultraThinMaterial)
                )
                .overlay(RoundedRectangle(cornerRadius: 36).stroke(Color.white, lineWidth: 1))
                .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
        )
    }
    
    // MARK: - 热量明细标题 (43:3150)
    // shadow-[0px_4px_6px_0px_rgba(201,201,201,0.1)]
    // 按钮: bg-[rgba(255,255,255,0.6)], border-white, h-[40px], pl-[14px] pr-[8px], rounded-[999px]
    // 内容: gap-[4px]
    // 位置: 水平居中
    private var foodListHeader: some View {
        // 标题 - 14px, #4d4d4d
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
    
    // MARK: - 食物清单列表 (43:3160)
    private var foodListItems: some View {
        // 根据食材数量动态设置间距：< 6 个用 7，>= 6 个用 6
        let foodCount = analysisData?.foods.count ?? 0
        let spacing: CGFloat = foodCount < 6 ? 7 : 6
        
        // 分析非蛋白热量，获取每个食材的等级
        let calorieLevels = analysisData?.foods != nil
            ? NonProteinCalorieAnalyzer.analyze(foods: analysisData!.foods)
            : [:]
        
        return VStack(spacing: spacing) {
            if let foods = analysisData?.foods {
                ForEach(foods, id: \.name) { food in
                    // 根据分析结果决定图标颜色
                    let level = calorieLevels[food.name] ?? .normal
                    let iconColor: Color = {
                        switch level {
                        case .high:    return highCalorieColor    // 红色（过高）
                        case .normal:  return normalCalorieColor  // 蓝色（正常）
                        case .healthy: return healthyCalorieColor // 绿色（健康）
                        }
                    }()
                    
                    FoodRow(
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

// MARK: - 食材列表组件 (43:3161)
// backdrop-blur-[3px], bg-[rgba(255,255,255,0.5)], border-white
// rounded-[999px], shadow-[0px_4px_6px_0px_rgba(201,201,201,0.1)]
// pl-[22px] pr-[16px] height-[68px]
private struct FoodRow: View {
    let iconGradientColor: Color
    let name: String
    let cook: String
    let kcal: Int
    let carbs: Int
    let proteins: Int
    let fats: Int
    
    /// 根据食物名称匹配的图标名称
    private var iconName: String {
        FoodIconMapper.getIconName(for: name)
    }
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    private let shadowColor = Color(red: 201/255, green: 201/255, blue: 201/255)
    
    var body: some View {
        HStack(spacing: 0) {
            // 食物图标 32x32
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
                // 食物名称 14px medium #151515
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.07)
                    .foregroundColor(textPrimary)
                
                // 营养信息：碳水 • 蛋白 • 脂肪
                HStack(spacing: 0) {
                    Text("碳水 \(carbs)g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    // Text(" • ")
                    //     .font(.system(size: 12))
                    //     .foregroundColor(textTertiary)
                    
                    Text(" 蛋白质 \(proteins)g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    // Text(" • ")
                    //     .font(.system(size: 12))
                    //     .foregroundColor(textTertiary)
                    
                    Text(" 脂肪 \(fats)g")
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
        .frame(height: 68) // 固定高度，内部 spacing 调整不影响整体高度
        .background(
            Capsule()
                .fill(Color.white.opacity(0.5))
                .background(Capsule().fill(.ultraThinMaterial))
                .overlay(Capsule().stroke(Color.white, lineWidth: 1))
                .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
        )
    }
}

// MARK: - 营养素列组件
/// 展示单个营养素的标签和数值
private struct NutrientColumn: View {
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
//#Preview {
//    FoodNutritionalView()
//}

#Preview("双层芝士汉堡") {
    FoodNutritionalView(
        analysisData: FoodAnalysisData(
            foodName: "双层芝士汉堡",
            foods: [
                FoodItem(name: "面包", cook: "烘烤", kcal: 250, carbs: 35, proteins: 8, fats: 7),
                FoodItem(name: "牛肉饼", cook: "煎制", kcal: 280, carbs: 0, proteins: 25, fats: 19),
                FoodItem(name: "芝士", cook: "融化", kcal: 120, carbs: 0, proteins: 10, fats: 10)
            ],
            nutrition: Nutrition(
                energyKcal: 650, proteinG: 43, fatG: 36, carbG: 35,
                fiberG: 1, sodiumMg: 1200, sugarG: 1, satFatG: 12
            ),
            confidence: 0.95,
            isBalanced: false,
            nutritionSummary: "高热量、高脂肪，蛋白质丰富但缺乏蔬菜。",
            highQualityProteins: ["牛肉", "芝士"],
            overallEvaluation: OverallEvaluation(
                aiIsBalanced: false,
                riskLevel: "HIGH",
                impactStrategy: "FULL_RISK_ANALYSIS",
                overallScore: 60,
                tagSummaries: nil
            ),
            impact: ImpactAnalysis(
                primaryText: "这顿饭脂肪和盐分偏高，膳食纤维严重不足，蔬菜几乎缺失。",
                shortTerm: "短期内可能引起饱腹感过强但消化负担重，因高油高盐容易口渴、轻微水肿，并影响血糖血脂的即时波动。",
                midTerm: "如果持续这样饮食几周到几个月，可能逐渐出现体重上升、血压偏高、肠道蠕动减慢导致便秘，以及血脂异常的趋势。",
                longTerm: "长期如此可能增加患高血压、心血管疾病和代谢综合征的风险，尤其是饱和脂肪和钠摄入过高、纤维过低的组合对慢性病影响较为显著。",
                riskTags: ["LOW_SUGAR", "VERY_LOW_FIBER", "HIGH_SAT_FAT", "HIGH_SODIUM"]
            )
        )
    )
}

#Preview("中式家常便当") {
    FoodNutritionalView(
        analysisData: FoodAnalysisData(
            foodName: "中式家常便当",
            foods: [
                FoodItem(name: "饺子", cook: "水煮", kcal: 350, carbs: 60, proteins: 12, fats: 4),
                FoodItem(name: "香肠", cook: "蒸煮", kcal: 280, carbs: 1, proteins: 14, fats: 22),
                FoodItem(name: "卤肉", cook: "卤制", kcal: 220, carbs: 2, proteins: 20, fats: 12),
                FoodItem(name: "炒菠菜", cook: "清炒", kcal: 50, carbs: 7, proteins: 4, fats: 1),
                FoodItem(name: "酸菜", cook: "炒制", kcal: 100, carbs: 18, proteins: 2, fats: 1),
                FoodItem(name: "辣椒酱", cook: "腌制", kcal: 50, carbs: 10, proteins: 1, fats: 2)
            ],
            nutrition: Nutrition(
                energyKcal: 1050, proteinG: 53, fatG: 42, carbG: 98,
                fiberG: 8, sodiumMg: 1800, sugarG: 10, satFatG: 12
            ),
            confidence: 0.93,
            isBalanced: true,
            nutritionSummary: "营养均衡，蛋白质和蔬菜搭配合理。",
            highQualityProteins: [],
            overallEvaluation: OverallEvaluation(
                aiIsBalanced: true,
                riskLevel: "HIGH",
                impactStrategy: "FULL_RISK_ANALYSIS",
                overallScore: 70,
                tagSummaries: nil
            ),
            impact: ImpactAnalysis(
                primaryText: "这顿饭饱和脂肪和钠含量偏高，虽蛋白质和蔬菜搭配尚可，但长期如此可能带来健康风险。",
                shortTerm: "短期内，高钠摄入可能导致口渴、水肿和血压短暂升高，同时高饱和脂肪的饮食可能使餐后血脂上升，增加血液黏稠度，让人感觉疲倦或头脑不清醒。",
                midTerm: "持续几周到几个月这样饮食，可能逐渐导致体重增加，尤其是体脂上升，血压也可能开始趋于偏高，血脂异常的风险随之提高。",
                longTerm: "长期保持这类饮食模式，可能增加患高血压、心血管疾病和代谢综合征的风险，特别是高饱和脂肪和高钠的组合对血管健康的负面影响较为明确。",
                riskTags: ["MEDIUM_FIBER", "LOW_SUGAR", "HIGH_SAT_FAT", "HIGH_SODIUM"]
            )
        )
    )
}
