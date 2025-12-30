//
//  OnboardingContainerView.swift
//  Flow
//
//  Onboarding 容器视图 - 管理页面切换和进度显示
//  采用 Oportun 设计风格（纯白背景、简洁线条）
//  Created on 2025-12-28.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        OnboardingPageContainer {
            VStack(spacing: 0) {
                // 1. 顶部导航栏 (置顶，符合 iOS 习惯)
                OnboardingNavigationBar(
                    showBackButton: true,
                    showCancelButton: false,
                    onBack: {
                        if viewModel.isFirstPage {
                            dismiss()
                        } else {
                            viewModel.previousPage()
                        }
                    },
                    onCancel: {
                        dismiss()
                    }
                )
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
                .padding(.top, 8) // 稍微给点顶部呼吸空间
                
                // 2. 进度条 (放在导航栏下方，作为视觉分割)
                progressBar
                    .padding(.horizontal, OnboardingDesign.horizontalPadding + 4) // 稍微内缩一点，更精致
                    .padding(.top, 16)
                
                // 3. 页面标题
                OnboardingTitleView(
                    title: viewModel.currentPage.title,
                    subtitle: viewModel.currentPage.subtitle
                )
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
                .padding(.top, 32) // 增加标题上方的留白
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
                
                // 4. 页面内容 (使用 switch 实现，禁止滑动切换)
                VStack {
                    switch viewModel.currentPage {
                    case .healthGoal:
                        HealthGoalView(viewModel: viewModel)
                    case .activityLevel:
                        ActivityLevelView(viewModel: viewModel)
                    case .nickname:
                        NicknameInputView(viewModel: viewModel)
                    case .gender:
                        GenderSelectionView(viewModel: viewModel)
                    case .birthYear:
                        AgeSelectionView(viewModel: viewModel)
                    case .bodyMeasurement:
                        BodyMeasurementView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 撑满剩余空间
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)
                
                // 5. 底部按钮 (固定底部，在安全区域内)
                OnboardingPrimaryButton(
                    title: viewModel.isLastPage ? "完成" : "下一步",
                    isEnabled: viewModel.canProceed,
                    isLoading: viewModel.isSubmitting
                ) {
                    if viewModel.isLastPage {
                        Task {
                            await viewModel.submitProfile()
                        }
                    } else {
                        viewModel.nextPage()
                    }
                }
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
                .padding(.bottom, 32) // 增加底部安全区域边距
            }
            .onChange(of: viewModel.currentPage) { oldValue, newValue in
                // 页面切换时自动收起键盘
                UIApplication.shared.endEditing()
            }
        }
        .alert("提示", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "发生未知错误")
        }
    }
    
    // MARK: - 进度条
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                Rectangle()
                    .fill(OnboardingDesign.borderColor)
                    .frame(height: 4)
                
                // 进度条
                Rectangle()
                    .fill(OnboardingDesign.accentColor)
                    .frame(width: geometry.size.width * viewModel.progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Extensions

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingContainerView()
}
