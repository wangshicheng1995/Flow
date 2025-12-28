//
//  HealthGoalView.swift
//  Flow
//
//  Onboarding 页面 5: 健康目标选择（最后一页）
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct HealthGoalView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // 健康目标选项
                ForEach(HealthGoal.allCases, id: \.self) { goal in
                    HealthGoalCard(
                        goal: goal,
                        isSelected: viewModel.userProfile.healthGoal == goal
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.userProfile.healthGoal = goal
                        }
                    }
                }
                
                // 热量推荐预览
                calorieRecommendation
                
                // 底部间距
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
    
    // MARK: - 热量推荐卡片
    private var calorieRecommendation: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
                
                Text("根据你的目标，每日建议摄入")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(viewModel.userProfile.recommendedDailyCalories)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("千卡")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 12, y: 6)
        .padding(.top, 8)
    }
}

// MARK: - 健康目标卡片
struct HealthGoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [goalColor, goalColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(goal.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 选中指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(isSelected ? goalColor : Color.gray.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected
                                    ? goalColor.opacity(0.5)
                                    : Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? goalColor.opacity(0.15) : .black.opacity(0.04),
                radius: isSelected ? 10 : 6,
                y: isSelected ? 5 : 3
            )
        }
        .buttonStyle(.plain)
    }
    
    // 根据目标类型返回不同颜色
    private var goalColor: Color {
        switch goal {
        case .loseWeight: return .blue
        case .maintain: return .green
        case .gainWeight: return .orange
        case .improveHealth: return .pink
        case .controlBloodSugar: return .purple
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        HealthGoalView(viewModel: OnboardingViewModel())
    }
}
