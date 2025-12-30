//
//  GetStartedView.swift
//  Flow
//
//  Onboarding 第二页 - 功能介绍与开始使用
//  参考 Oportun 设计风格
//  Created on 2025-12-29.
//

import SwiftUI
import AuthenticationServices

struct GetStartedView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 纯白背景
            OnboardingDesign.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部插画区域
                illustrationSection
                
                Spacer()
                
                // 文字内容区域
                contentSection
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // 底部按钮
                getStartedButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }
    
    // MARK: - 顶部插画
    private var illustrationSection: some View {
        GeometryReader { geometry in
            Image("banner2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
                .clipped()
        }
        .frame(height: 350)  // 固定高度，避免使用废弃的 UIScreen.main
    }
    
    // MARK: - 文字内容
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 主标题
            Text("轻松掌控\n你的健康目标")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(OnboardingDesign.primaryTextColor)
                .lineSpacing(4)
            
            // 副标题描述
            Text("拍照记录饮食，智能分析营养成分，追踪每日摄入。用 Flow 开启更健康的生活方式。")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(OnboardingDesign.secondaryTextColor)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Get Started 按钮
    private var getStartedButton: some View {
        Button(action: {
            performAppleSignIn()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18, weight: .medium))
                Text("使用 Apple 账户登录")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(OnboardingDesign.primaryTextColor)
            .cornerRadius(28)
        }
    }
    
    // MARK: - Apple Sign In
    private func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AppleSignInDelegate.shared
        controller.presentationContextProvider = AppleSignInDelegate.shared
        controller.performRequests()
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppleSignInDelegate()
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 1. 优先查找活跃的 Key Window
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
            return window
        }
        
        // 2. 尝试使用 WindowScene 创建临时 Window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return UIWindow(windowScene: windowScene)
        }
        
        // 3. 最后的兜底 (虽然在 SwiftUI App 生命周期中几乎不会发生)
        return UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        AuthenticationManager.shared.handleSignIn(result: .success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AuthenticationManager.shared.handleSignIn(result: .failure(error))
    }
}

#Preview {
    GetStartedView()
}
