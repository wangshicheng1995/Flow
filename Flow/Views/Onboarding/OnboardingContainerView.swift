//
//  OnboardingContainerView.swift
//  Flow
//
//  Onboarding 容器视图 - 管理页面切换和进度显示
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 背景渐变
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // 进度指示器
                progressIndicator
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // 页面标题
                titleView
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                // 页面内容
                TabView(selection: $viewModel.currentPage) {
                    NicknameInputView(viewModel: viewModel)
                        .tag(OnboardingPage.nickname)
                    
                    GenderSelectionView(viewModel: viewModel)
                        .tag(OnboardingPage.gender)
                    
                    BirthYearSelectionView(viewModel: viewModel)
                        .tag(OnboardingPage.birthYear)
                    
                    BodyMeasurementView(viewModel: viewModel)
                        .tag(OnboardingPage.bodyMeasurement)
                    
                    ActivityLevelView(viewModel: viewModel)
                        .tag(OnboardingPage.activityLevel)
                    
                    HealthGoalView(viewModel: viewModel)
                        .tag(OnboardingPage.healthGoal)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                
                // 底部按钮
                bottomButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .alert("提示", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "发生未知错误")
        }
    }
    
    // MARK: - 背景渐变
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(hex: "1a1a2e"), Color(hex: "16213e")]
                : [Color(hex: "f8f9fa"), Color(hex: "e9ecef")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - 顶部导航栏
    private var headerView: some View {
        HStack {
            // 返回按钮
            if !viewModel.isFirstPage {
                Button(action: {
                    viewModel.previousPage()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // 跳过按钮（可选）
            // Button("跳过") { }
            //     .font(.system(size: 16, weight: .medium))
            //     .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 进度指示器
    private var progressIndicator: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(height: 8)
                
                // 进度条
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.progress)
            }
        }
        .frame(height: 8)
    }
    
    // MARK: - 标题区域
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.currentPage.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(viewModel.currentPage.subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
    }
    
    // MARK: - 底部按钮
    private var bottomButtons: some View {
        Button(action: {
            if viewModel.isLastPage {
                Task {
                    await viewModel.submitProfile()
                }
            } else {
                viewModel.nextPage()
            }
        }) {
            HStack(spacing: 8) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(viewModel.isLastPage ? "进入 Flow" : "继续")
                        .font(.system(size: 18, weight: .semibold))
                    
                    if !viewModel.isLastPage {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        viewModel.canProceed
                            ? LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .shadow(color: viewModel.canProceed ? Color.accentColor.opacity(0.3) : .clear, radius: 12, y: 6)
        }
        .disabled(!viewModel.canProceed || viewModel.isSubmitting)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed)
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
