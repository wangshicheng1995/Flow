//
//  NicknameInputView.swift
//  Flow
//
//  Onboarding 页面: 昵称输入
//  采用 Oportun 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct NicknameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 输入区域
            inputSection
            
            Spacer()
        }
        .padding(.horizontal, OnboardingDesign.horizontalPadding)
        .padding(.top, 32)
        .onAppear {
            // 自动填充 Apple 账户名称（如果有且昵称为空）
            if viewModel.userProfile.nickname.isEmpty {
                let authManager = AuthenticationManager.shared
                // 优先使用 givenName（名），其次是 fullName
                if !authManager.userGivenName.isEmpty {
                    viewModel.userProfile.nickname = authManager.userGivenName
                } else if !authManager.userFullName.isEmpty {
                    viewModel.userProfile.nickname = authManager.userFullName
                }
            }
            
            // 自动聚焦输入框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - 输入区域
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 输入框
            TextField("请输入昵称", text: $viewModel.userProfile.nickname)
                .font(.system(size: OnboardingDesign.inputFontSize))
                .foregroundColor(OnboardingDesign.primaryTextColor)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 16)
                .frame(height: OnboardingDesign.inputHeight)
                .background(
                    RoundedRectangle(cornerRadius: OnboardingDesign.cornerRadius)
                        .stroke(OnboardingDesign.borderColor, lineWidth: 1)
                )
            
            // 字符计数提示
            if !viewModel.userProfile.nickname.isEmpty {
                HStack {
                    Spacer()
                    Text("\(viewModel.userProfile.nickname.count) / 20")
                        .font(.system(size: 14))
                        .foregroundColor(
                            viewModel.userProfile.nickname.count > 20
                                ? .red
                                : OnboardingDesign.secondaryTextColor
                        )
                }
            }
        }
    }
}

#Preview {
    OnboardingPageContainer {
        VStack {
            OnboardingTitleView(title: "设置昵称", subtitle: "希望 Flow 怎么称呼你")
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
            NicknameInputView(viewModel: OnboardingViewModel())
        }
    }
}
