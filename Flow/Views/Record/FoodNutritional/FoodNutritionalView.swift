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
    @Environment(\.selectedTab) private var selectedTab
    
    /// 食物分析数据
    var analysisData: FoodAnalysisData?
    
    /// 拍摄的食物图片
    var capturedImage: UIImage?
    
    // MARK: - 分阶段加载状态
    /// 第二阶段卡片是否已加载（血糖趋势、饮食建议等）
    @State private var phase2Loaded = false
    /// 血糖趋势卡片是否可见
    @State private var glucoseTrendVisible = false
    /// 饮食建议卡片是否可见
    @State private var eatingTipsVisible = false
    
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
     private let bgColor = Color(red: 249/255, green: 248/255, blue: 246/255) // #F9F8F6 暖白色
//    private let bgColor = Color(red: 250/255, green: 247/255, blue: 245/255) // #FAF7F5
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255) // #151515
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255) // #4d4d4d
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255) // #999
    private let shadowColor = Color(red: 201/255, green: 201/255, blue: 201/255) // rgba(201,201,201,0.1)
    
    // MARK: - 食材热量等级颜色（参考图二）
    private let highCalorieColor = Color(red: 239/255, green: 83/255, blue: 80/255)   // #EF5350 红色（过高）
    private let normalCalorieColor = Color(red: 100/255, green: 181/255, blue: 246/255) // #64B5F6 蓝色（正常）
    private let healthyCalorieColor = Color(red: 29/255, green: 194/255, blue: 134/255) // #1DC286 绿色（健康）
    
    // MARK: - 血糖图表颜色
    private let glucoseLineColor = Color(red: 255/255, green: 149/255, blue: 0/255) // 橙色
    private let glucoseGoodColor = Color(red: 76/255, green: 175/255, blue: 80/255)  // 绿色
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // ========== 第一阶段：立即显示 ==========
                    // 总览卡片
                    OverallCardView(
                        calories: analysisData?.nutrition.energyKcal,
                        carbs: analysisData?.nutrition.carbG ?? 0,
                        proteins: analysisData?.nutrition.proteinG ?? 0,
                        fats: analysisData?.nutrition.fatG ?? 0,
                        capturedImage: capturedImage
                    )
                    
                    // 食物清单（标题 + 列表）
                    FoodListView(foods: analysisData?.foods)
                    
                    // ========== 第二阶段：延迟加载，带滑入动画 ==========
                    // 血糖趋势卡片
                    if phase2Loaded {
                        GlucoseTrendCardView(data: mockGlucoseTrendData)
                            .opacity(glucoseTrendVisible ? 1 : 0)
                            .offset(x: glucoseTrendVisible ? 0 : -60)
                            .scaleEffect(glucoseTrendVisible ? 1 : 0.95)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(0.1),
                                value: glucoseTrendVisible
                            )
                    } else {
                        // 骨架屏占位
                        SkeletonCard(height: 300)
                    }
                    
                    // 饮食建议卡片
                    if phase2Loaded {
                        EatingTipsCardView(data: mockEatingTipsData)
                            .opacity(eatingTipsVisible ? 1 : 0)
                            .offset(x: eatingTipsVisible ? 0 : -60)
                            .scaleEffect(eatingTipsVisible ? 1 : 0.95)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(0.2),
                                value: eatingTipsVisible
                            )
                    } else {
                        // 骨架屏占位
                        SkeletonCard(height: 180)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(bgColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 左侧返回按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // 先关闭当前页面，再切换到首页 Tab
                        dismiss()
                        selectedTab.wrappedValue = .today
                    }) {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(textPrimary)
                            )
                            .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
                    }
                }
                
                // 中间食物名称
                ToolbarItem(placement: .principal) {
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
                }
            }
            .toolbarBackground(bgColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                triggerPhase2Loading()
            }
        }
    }
    
    // MARK: - 第二阶段加载触发
    private func triggerPhase2Loading() {
        // 模拟第二阶段数据加载延迟（实际项目中可能是真实的 API 调用）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase2Loaded = true
            
            // 错开触发每个卡片的滑入动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                glucoseTrendVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                eatingTipsVisible = true
            }
        }
    }
    
    // MARK: - Mock 数据（开发阶段使用，后续替换为真实 API 数据）
    private var mockGlucoseTrendData: GlucoseTrendData {
        GlucoseTrendData(
            timePoints: [0, 15, 30, 45, 60, 90, 120],
            glucoseValues: [95, 125, 148, 138, 118, 102, 94],
            peakValue: 148,
            peakTimeMinutes: 30,
            impactLevel: "MEDIUM",
            recoveryTimeMinutes: 110,
            normalRangeLow: 70,
            normalRangeHigh: 140
        )
    }
    
    private var mockEatingTipsData: EatingTipsData {
        EatingTipsData(
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
    }

}

// MARK: - 骨架屏卡片组件
struct SkeletonCard: View {
    let height: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题占位
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 20, height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 100, height: 16)
                
                Spacer()
            }
            
            // 内容占位
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(height: height - 80)
            
            // 底部信息占位
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 40, height: 10)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 50, height: 16)
                    }
                }
            }
        }
        .padding(20)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                )
        )
        .opacity(isAnimating ? 0.6 : 1)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

//#Preview {
//    FoodNutritionalView()
//}

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
