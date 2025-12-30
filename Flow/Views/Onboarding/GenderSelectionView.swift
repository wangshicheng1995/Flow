//
//  GenderSelectionView.swift
//  Flow
//
//  Onboarding 页面: 性别选择
//  采用 Oportun 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 性别选项列表
            ForEach(Gender.allCases, id: \.self) { gender in
                GenderRowCard(gender: gender, isSelected: viewModel.userProfile.gender == gender) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.userProfile.gender = gender
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, OnboardingDesign.horizontalPadding)
        .padding(.top, 32)
    }
}

// MARK: - 性别行卡片 (复刻 FoodList 样式)
struct GenderRowCard: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    // 颜色常量 (参考 FoodListView)
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
                    
                    Image(systemName: gender.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? accentColor : Color.gray)
                }
                
                // 标题
                Text(gender.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textPrimary)
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
                    // 未选中显示空圆圈 (可选，增加可点感)
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundColor(Color.gray.opacity(0.3))
                        .padding(.trailing, 12)
                }
            }
            .padding(.leading, 22)
            .padding(.trailing, 16)
            .frame(height: 68) // 保持与 FoodRow 一致的高度
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

// MARK: - 按钮缩放样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingPageContainer {
        VStack {
            OnboardingTitleView(title: "你的性别是？", subtitle: "这将帮助我们更准确地计算你的每日需求")
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
            GenderSelectionView(viewModel: OnboardingViewModel())
        }
    }
}
