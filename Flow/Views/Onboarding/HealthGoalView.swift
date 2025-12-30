//
//  HealthGoalView.swift
//  Flow
//
//  Onboarding 页面: 健康目标选择（最后一页）
//  采用 Oportun 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct HealthGoalView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // 健康目标选项
                ForEach(HealthGoal.allCases, id: \.self) { goal in
                    GoalRowCard(
                        goal: goal,
                        isSelected: viewModel.userProfile.healthGoal == goal
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.userProfile.healthGoal = goal
                        }
                    }
                }
                
                // 底部间距
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, OnboardingDesign.horizontalPadding)
            .padding(.top, 32)
        }
    }
}

// MARK: - 目标选择行 (复刻 Gender/FoodList 样式)
struct GoalRowCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void
    
    private let textPrimary = OnboardingDesign.primaryTextColor
    private let accentColor = OnboardingDesign.accentColor
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // 左侧图标 (带圆形背景)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isSelected ? accentColor : Color.gray).opacity(0.15),
                                    (isSelected ? accentColor : Color.gray).opacity(0.08),
                                    (isSelected ? accentColor : Color.gray).opacity(0.02)
                                ],
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? accentColor : Color.gray)
                }
                
                // 文字内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textPrimary)
                    
                    Text(goal.description)
                        .font(.system(size: 12))
                        .foregroundColor(OnboardingDesign.secondaryTextColor)
                }
                .padding(.leading, 12)
                
                Spacer()
                
                // 右侧选中标记
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                        .padding(.trailing, 12)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // 未选中显示空圆圈
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundColor(Color.gray.opacity(0.3))
                        .padding(.trailing, 12)
                }
            }
            .padding(.leading, 22)
            .padding(.trailing, 16)
            .frame(height: 72) // 略高一点以容纳两行文字
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
        .buttonStyle(ScaleButtonStyle())
    }
}

// ScaleButtonStyle 已在 GenderSelectionView.swift 中定义为 internal，此处直接复用

#Preview {
    OnboardingPageContainer {
        VStack {
            OnboardingTitleView(title: "你的健康目标是？", subtitle: "我们会根据你的目标给出建议")
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
            HealthGoalView(viewModel: OnboardingViewModel())
        }
    }
}
