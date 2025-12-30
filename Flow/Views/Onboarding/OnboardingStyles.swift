//
//  OnboardingStyles.swift
//  Flow
//
//  Onboarding 统一设计系统
//  基于 Oportun 设计风格提取
//  Created on 2025-12-29.
//

import SwiftUI

// MARK: - 设计常量
struct OnboardingDesign {
    // 颜色
    static let backgroundColor = Color.white
    static let primaryTextColor = Color.black
    static let secondaryTextColor = Color(hex: "666666")
    static let accentColor = Color(hex: "FF8B60")  // Flow 品牌主题色
    static let borderColor = Color(hex: "E5E5E5")
    static let selectedBorderColor = Color(hex: "FF8B60")  // Flow 品牌主题色
    
    // 字体大小
    static let titleFontSize: CGFloat = 28
    static let subtitleFontSize: CGFloat = 16
    static let inputFontSize: CGFloat = 17
    static let buttonFontSize: CGFloat = 18
    
    // 间距
    static let horizontalPadding: CGFloat = 24
    static let inputHeight: CGFloat = 56
    static let buttonHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 28
}

// MARK: - Onboarding 标题组件
struct OnboardingTitleView: View {
    let title: String
    let subtitle: String?
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: OnboardingDesign.titleFontSize, weight: .bold))
                .foregroundColor(OnboardingDesign.primaryTextColor)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: OnboardingDesign.subtitleFontSize, weight: .regular))
                    .foregroundColor(OnboardingDesign.secondaryTextColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Onboarding 输入框样式
struct OnboardingTextFieldStyle: TextFieldStyle {
    let placeholder: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: OnboardingDesign.inputFontSize))
            .foregroundColor(OnboardingDesign.primaryTextColor)
            .padding(.horizontal, 16)
            .frame(height: OnboardingDesign.inputHeight)
            .background(
                RoundedRectangle(cornerRadius: OnboardingDesign.cornerRadius)
                    .stroke(OnboardingDesign.borderColor, lineWidth: 1)
            )
    }
}

// MARK: - Onboarding 选择卡片
struct OnboardingSelectionCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    let content: () -> Content
    
    init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                content()
                
                Spacer()
                
                // 选中指示器
                ZStack {
                    Circle()
                        .stroke(isSelected ? OnboardingDesign.selectedBorderColor : OnboardingDesign.borderColor, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(OnboardingDesign.selectedBorderColor)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: OnboardingDesign.inputHeight)
            .background(
                RoundedRectangle(cornerRadius: OnboardingDesign.cornerRadius)
                    .stroke(OnboardingDesign.borderColor, lineWidth: 1)  // 边框始终保持灰色
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Onboarding 主按钮
struct OnboardingPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(title: String, isEnabled: Bool = true, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: OnboardingDesign.buttonFontSize, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: OnboardingDesign.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: OnboardingDesign.buttonCornerRadius)
                    .fill(isEnabled ? Color.black : Color.gray.opacity(0.4))
            )
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Onboarding 导航栏
struct OnboardingNavigationBar: View {
    let showBackButton: Bool
    let showCancelButton: Bool
    let onBack: () -> Void
    let onCancel: (() -> Void)?
    
    init(showBackButton: Bool = true, showCancelButton: Bool = false, onBack: @escaping () -> Void, onCancel: (() -> Void)? = nil) {
        self.showBackButton = showBackButton
        self.showCancelButton = showCancelButton
        self.onBack = onBack
        self.onCancel = onCancel
    }
    
    var body: some View {
        HStack {
            // 返回按钮
            if showBackButton {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(OnboardingDesign.primaryTextColor)
                        .frame(width: 44, height: 44)
                }
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // 取消按钮
            if showCancelButton, let onCancel = onCancel {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingDesign.accentColor)
                }
            }
        }
    }
}

// MARK: - Onboarding 页面容器
struct OnboardingPageContainer<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            OnboardingDesign.backgroundColor
                .ignoresSafeArea()
            
            content()
        }
    }
}
