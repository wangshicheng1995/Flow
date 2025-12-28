//
//  LazyLoadAnimationTest.swift
//  Flow
//
//  独立测试文件 - 模拟 X (Twitter) 风格的懒加载滑入动画
//  测试完毕后可直接删除此文件，不影响任何现有代码
//
//  使用方法:
//  1. 在模拟器/真机上运行
//  2. 点击「模拟第二阶段加载」观察滑入动画效果
//  3. 点击「重置」可反复测试
//

import SwiftUI

// MARK: - 懒加载动画测试视图
struct LazyLoadAnimationTestView: View {
    
    // 模拟第一阶段数据（快速返回的基础数据）
    @State private var phase1Loaded = false
    
    // 模拟第二阶段数据（延迟返回的详细数据）
    @State private var phase2Foods: [TestMockFoodItem] = []
    @State private var isLoadingPhase2 = false
    
    // MARK: - 设计稿精确颜色（与 FoodNutritionalView 保持一致）
    private let bgColor = Color(red: 249/255, green: 248/255, blue: 246/255)
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    private let shadowColor = Color(red: 201/255, green: 201/255, blue: 201/255)
    
    // 食材热量等级颜色
    private let highCalorieColor = Color(red: 239/255, green: 83/255, blue: 80/255)
    private let normalCalorieColor = Color(red: 100/255, green: 181/255, blue: 246/255)
    private let healthyCalorieColor = Color(red: 29/255, green: 194/255, blue: 134/255)
    
    // Mock 数据
    private let mockFoods: [TestMockFoodItem] = [
        TestMockFoodItem(name: "米饭", kcal: 232, carbs: 50.8, proteins: 4.3, fats: 0.5, level: .normal),
        TestMockFoodItem(name: "红烧肉", kcal: 512, carbs: 8.2, proteins: 25.6, fats: 42.3, level: .high),
        TestMockFoodItem(name: "清炒时蔬", kcal: 85, carbs: 12.1, proteins: 3.2, fats: 4.5, level: .healthy),
        TestMockFoodItem(name: "紫菜蛋花汤", kcal: 45, carbs: 2.8, proteins: 4.1, fats: 2.2, level: .healthy),
        TestMockFoodItem(name: "水果拼盘", kcal: 120, carbs: 28.5, proteins: 1.2, fats: 0.3, level: .normal),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // 说明卡片
                    instructionCard
                    
                    // 第一阶段：总览卡片（立即显示）
                    if phase1Loaded {
                        overallCard
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // 热量明细标题
                    foodListHeader
                    
                    // 第二阶段：食物列表（带滑入动画）
                    foodListSection
                    
                    // 控制按钮
                    controlButtons
                        .padding(.top, 20)
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(bgColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(healthyCalorieColor)
                            .frame(width: 8, height: 8)
                        Text("懒加载动画测试")
                            .font(.system(size: 12, weight: .regular))
                            .tracking(0.12)
                            .foregroundColor(textSecondary)
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
        }
        .onAppear {
            // 模拟第一阶段快速加载
            withAnimation(.easeOut(duration: 0.3)) {
                phase1Loaded = true
            }
        }
    }
    
    // MARK: - 说明卡片
    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🧪")
                    .font(.title2)
                Text("X (Twitter) 风格懒加载测试")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
            }
            Text("点击下方按钮模拟第二阶段 AI 调用返回，观察食物列表的滑入动画效果。如果体验良好，可以应用到正式代码中。")
                .font(.system(size: 12))
                .foregroundColor(textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.blue.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 总览卡片（与 FoodNutritionalView 保持一致的样式）
    private var overallCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Text("本餐卡路里：")
                    .font(.system(size: 12, weight: .regular))
                    .tracking(0.12)
                    .foregroundColor(textSecondary)
                    .padding(.vertical, 8)
                
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("994")
                            .font(.system(size: 48, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(textPrimary)
                        
                        Text("千卡")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(textTertiary)
                            .offset(y: -5)
                    }
                    
                    Spacer()
                    
                    // 加载指示器
                    if isLoadingPhase2 && phase2Foods.isEmpty {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            
            // 营养素展示区域
            HStack(spacing: 77) {
                NutrientColumnTest(label: "碳水", value: 102, color: Color(red: 255/255, green: 193/255, blue: 7/255))
                NutrientColumnTest(label: "蛋白质", value: 38, color: Color(red: 76/255, green: 175/255, blue: 80/255))
                NutrientColumnTest(label: "脂肪", value: 50, color: Color(red: 33/255, green: 150/255, blue: 243/255))
            }
            .padding(.top, 1)
            .padding(.leading, 4)
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
    
    // MARK: - 热量明细标题
    private var foodListHeader: some View {
        HStack {
            Text("热量明细")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(textSecondary)
            
            if isLoadingPhase2 && phase2Foods.isEmpty {
                ProgressView()
                    .scaleEffect(0.6)
                    .padding(.leading, 8)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.6))
                .overlay(Capsule().stroke(Color.white, lineWidth: 1))
        )
        .shadow(color: shadowColor.opacity(0.1), radius: 3, x: 0, y: 4)
    }
    
    // MARK: - 食物列表区域
    private var foodListSection: some View {
        VStack(spacing: 7) {
            if phase2Foods.isEmpty && !isLoadingPhase2 {
                // 骨架屏占位符
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonFoodRow()
                }
            } else if phase2Foods.isEmpty && isLoadingPhase2 {
                // 加载中的骨架屏（带脉冲动画）
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonFoodRow(isAnimating: true)
                }
            } else {
                // 实际数据 - 带滑入动画
                ForEach(Array(phase2Foods.enumerated()), id: \.element.id) { index, food in
                    AnimatedFoodRow(
                        food: food,
                        delay: Double(index) * 0.1,
                        iconColor: colorForLevel(food.level)
                    )
                }
            }
        }
    }
    
    // MARK: - 控制按钮
    private var controlButtons: some View {
        VStack(spacing: 12) {
            Button(action: simulatePhase2Load) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("模拟第二阶段加载")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(phase2Foods.isEmpty && !isLoadingPhase2 ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(isLoadingPhase2 || !phase2Foods.isEmpty)
            
            Button(action: reset) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("重置动画")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .foregroundColor(textPrimary)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Helper
    private func colorForLevel(_ level: CalorieLevel) -> Color {
        switch level {
        case .high: return highCalorieColor
        case .normal: return normalCalorieColor
        case .healthy: return healthyCalorieColor
        }
    }
    
    // MARK: - 模拟加载逻辑
    private func simulatePhase2Load() {
        isLoadingPhase2 = true
        
        // 模拟 1.5 秒的 API 延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoadingPhase2 = false
            
            // 逐个添加数据以触发错开的滑入动画
            for (index, food) in mockFoods.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        phase2Foods.append(food)
                    }
                }
            }
        }
    }
    
    private func reset() {
        withAnimation(.easeOut(duration: 0.2)) {
            phase2Foods = []
            isLoadingPhase2 = false
        }
    }
}

// MARK: - Mock 数据模型（测试专用，避免与正式代码冲突）
struct TestMockFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let kcal: Int
    let carbs: Double
    let proteins: Double
    let fats: Double
    let level: CalorieLevel  // 使用现有的 CalorieLevel 枚举
}

// MARK: - 带滑入动画的食物行
struct AnimatedFoodRow: View {
    let food: TestMockFoodItem
    let delay: Double
    let iconColor: Color
    
    @State private var isVisible = false
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    var body: some View {
        HStack(spacing: 0) {
            // 食物图标
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.15),
                                iconColor.opacity(0.08),
                                iconColor.opacity(0.02)
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            // 食物名称和营养信息
            VStack(alignment: .leading, spacing: 8) {
                Text(food.name)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(-0.07)
                    .foregroundColor(textPrimary)
                
                HStack(spacing: 0) {
                    Text("碳水 \(Int(food.carbs))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    Text(" 蛋白质 \(Int(food.proteins))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                    
                    Text(" 脂肪 \(Int(food.fats))g")
                        .font(.system(size: 14, weight: .regular))
                        .tracking(-0.07)
                        .foregroundColor(textTertiary)
                }
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // 卡路里
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(food.kcal)")
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
        // ✨ 关键动画效果：从左侧滑入
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -60)
        .scaleEffect(isVisible ? 1 : 0.95)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7)
            .delay(delay),
            value: isVisible
        )
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - 骨架屏食物行
struct SkeletonFoodRow: View {
    var isAnimating: Bool = false
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 150, height: 12)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 50, height: 16)
                .padding(.trailing, 12)
        }
        .padding(.leading, 22)
        .padding(.trailing, 16)
        .frame(height: 68)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.gray.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(animating ? 0.5 : 1)
        .animation(
            isAnimating ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : nil,
            value: animating
        )
        .onAppear {
            if isAnimating {
                animating = true
            }
        }
    }
}

// MARK: - 营养素列组件
private struct NutrientColumnTest: View {
    let label: String
    let value: Int
    let color: Color
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textTertiary)
            }
            
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
#Preview("懒加载动画测试") {
    LazyLoadAnimationTestView()
}
