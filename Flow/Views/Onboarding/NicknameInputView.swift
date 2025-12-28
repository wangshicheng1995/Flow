//
//  NicknameInputView.swift
//  Flow
//
//  Onboarding 页面 0: 昵称输入
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct NicknameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 头像占位符
            avatarView
            
            // 输入区域
            inputSection
            
            // 提示文字
            hintText
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            // 自动聚焦输入框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - 头像视图
    private var avatarView: some View {
        ZStack {
            // Liquid Glass 效果背景
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            
            // 图标
            Image(systemName: "person.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    // MARK: - 输入区域
    private var inputSection: some View {
        VStack(spacing: 12) {
            TextField("输入你的昵称", text: $viewModel.userProfile.nickname)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .focused($isTextFieldFocused)
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isTextFieldFocused
                                        ? Color.accentColor.opacity(0.5)
                                        : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: isTextFieldFocused ? Color.accentColor.opacity(0.2) : .clear, radius: 12, y: 4)
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            
            // 字符计数
            if !viewModel.userProfile.nickname.isEmpty {
                Text("\(viewModel.userProfile.nickname.count) / 20")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(
                        viewModel.userProfile.nickname.count > 20
                            ? .red
                            : .secondary
                    )
            }
        }
    }
    
    // MARK: - 提示文字
    private var hintText: some View {
        Text("这个昵称会显示在你的个人资料中")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        NicknameInputView(viewModel: OnboardingViewModel())
    }
}
