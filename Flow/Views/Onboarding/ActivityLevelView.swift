//
//  ActivityLevelView.swift
//  Flow
//
//  Onboarding 页面 4: 日常活动水平选择
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // 活动水平选项
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    ActivityLevelCard(
                        level: level,
                        isSelected: viewModel.userProfile.activityLevel == level
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.userProfile.activityLevel = level
                        }
                    }
                }
                
                // 底部间距
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}

// MARK: - 活动水平卡片
struct ActivityLevelCard: View {
    let level: ActivityLevel
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
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: level.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(level.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 选中指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.3))
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
                                    ? Color.accentColor.opacity(0.5)
                                    : Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.15) : .black.opacity(0.04),
                radius: isSelected ? 10 : 6,
                y: isSelected ? 5 : 3
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        ActivityLevelView(viewModel: OnboardingViewModel())
    }
}
