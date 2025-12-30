//
//  AuthenticationManager.swift
//  Flow
//
//  Created on 2025-11-24.
//

import SwiftUI
import AuthenticationServices
import OSLog

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Flow", category: "Authentication")
    
    // 调试开关：true = 需要 Apple 登录，false = 跳过登录直接进入 Onboarding
    static let isAppleLoginEnabled = false // ← 设为 false 可在模拟器上调试 Onboarding
    
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("userIdentifier") var userIdentifier: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userFullName") var userFullName: String = ""
    @AppStorage("userFamilyName") var userFamilyName: String = ""
    @AppStorage("userGivenName") var userGivenName: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    private init() {
        // 当 Apple Sign In 关闭时，自动模拟登录状态，并进入 Onboarding 流程
        if !AuthenticationManager.isAppleLoginEnabled {
            // 生成或保留设备唯一标识符
            if userIdentifier.isEmpty {
                userIdentifier = "device_\(UUID().uuidString)"
                logger.info("📱 生成设备唯一标识符: \(self.userIdentifier)")
            }
            
            // 模拟已登录，但未完成 Onboarding → 这样会进入 OnboardingContainerView
            isAuthenticated = true
            hasCompletedOnboarding = false
            logger.info("🔧 调试模式：跳过 Apple 登录，进入 Onboarding 流程")
        }
    }
    
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                // 打印登录返回的详细信息（中文）
                logger.info("========================================")
                logger.info("✅ 登录成功！下面是登录完成后得到的数据：")
                logger.info("用户 ID (User ID): \(appleIDCredential.user)")
                
                if let fullName = appleIDCredential.fullName {
                    logger.info("全名 (Full Name): \(fullName.givenName ?? "") \(fullName.familyName ?? "")")
                    // 注意：全名和邮箱通常只在第一次登录时返回
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !name.isEmpty {
                        self.userFullName = name
                    }
                    
                    if let familyName = fullName.familyName {
                        self.userFamilyName = familyName
                    }
                    
                    if let givenName = fullName.givenName {
                        self.userGivenName = givenName
                    }
                } else {
                    logger.info("全名 (Full Name): 未返回 (可能非首次登录)")
                }
                
                if let email = appleIDCredential.email {
                    logger.info("邮箱 (Email): \(email)")
                    self.userEmail = email
                } else {
                    logger.info("邮箱 (Email): 未返回 (可能非首次登录或用户隐藏)")
                }
                
                if let identityToken = appleIDCredential.identityToken,
                   let tokenString = String(data: identityToken, encoding: .utf8) {
                    logger.info("身份令牌 (Identity Token): \(tokenString.prefix(20))... (已截断)")
                }
                
                if let authorizationCode = appleIDCredential.authorizationCode,
                   let codeString = String(data: authorizationCode, encoding: .utf8) {
                    logger.info("授权码 (Authorization Code): \(codeString.prefix(20))... (已截断)")
                }
                
                logger.info("========================================")
                
                // 保存用户 ID 并更新认证状态
                self.userIdentifier = appleIDCredential.user
                self.isAuthenticated = true
            }
            
        case .failure(let error):
            logger.error("❌ 登录失败: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        isAuthenticated = false
        userIdentifier = ""
        userEmail = ""
        userFullName = ""
        userFamilyName = ""
        userGivenName = ""
        hasCompletedOnboarding = false
    }
}
