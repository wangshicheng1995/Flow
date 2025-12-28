//
//  GenderSelectionView.swift
//  Flow
//
//  Onboarding 页面 1: 性别选择
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 性别选项
            ForEach(Gender.allCases, id: \.self) { gender in
                GenderOptionCard(
                    gender: gender,
                    isSelected: viewModel.userProfile.gender == gender
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.userProfile.gender = gender
                    }
                }
            }
            
            // 说明文字
            infoText
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 说明文字
    private var infoText: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text("性别信息用于计算基础代谢率，不会公开显示")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

// MARK: - 性别选项卡片
struct GenderOptionCard: View {
    let gender: Gender
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
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: gender.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                // 文字
                Text(gender.displayName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // 选中指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected
                                    ? Color.accentColor.opacity(0.5)
                                    : Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.2) : .black.opacity(0.05),
                radius: isSelected ? 12 : 8,
                y: isSelected ? 6 : 4
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        GenderSelectionView(viewModel: OnboardingViewModel())
    }
}
