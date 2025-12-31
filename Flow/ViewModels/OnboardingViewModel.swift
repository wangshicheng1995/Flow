//
//  OnboardingViewModel.swift
//  Flow
//
//  Onboarding 业务逻辑管理
//  负责管理用户资料收集流程和数据提交
//  Created on 2025-12-28.
//

import SwiftUI
import Combine

/// Onboarding 页面枚举
enum OnboardingPage: Int, CaseIterable {
    case healthGoal = 0       // 你的健康目标 (第1页)
    case activityLevel = 1    // 日常活动水平 (第2页)
    case nickname = 2         // 怎么称呼你
    case gender = 3           // 性别选择
    case birthYear = 4        // 出生年份
    case bodyMeasurement = 5  // 身高体重 (最后一页)
    
    var title: String {
        switch self {
        case .healthGoal: return "你的健康目标"
        case .activityLevel: return "日常活动水平"
        case .nickname: return "怎么称呼你"
        case .gender: return "你的性别"
        case .birthYear: return "你的出生年份"
        case .bodyMeasurement: return "你的身高体重"
        }
    }
    
    var subtitle: String {
        switch self {
        case .healthGoal: return "我们会根据目标给出建议"
        case .activityLevel: return "了解你的运动习惯"
        case .nickname: return "让我们更好地认识你"
        case .gender: return "用于计算基础代谢率"
        case .birthYear: return "年龄会影响热量需求"
        case .bodyMeasurement: return "精确计算你的每日热量"
        }
    }
}

/// Onboarding 视图模型
@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 当前页面索引 (默认从 HealthGoal 开始)
    @Published var currentPage: OnboardingPage = .healthGoal
    
    /// 用户资料
    @Published var userProfile: UserProfile
    
    /// 是否正在提交
    @Published var isSubmitting: Bool = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示错误
    @Published var showError: Bool = false
    
    // MARK: - Computed Properties
    
    /// 当前页面索引（数字）
    var currentPageIndex: Int {
        currentPage.rawValue
    }
    
    /// 总页数
    var totalPages: Int {
        OnboardingPage.allCases.count
    }
    
    /// 进度百分比
    var progress: Double {
        Double(currentPageIndex + 1) / Double(totalPages)
    }
    
    /// 是否是第一页
    var isFirstPage: Bool {
        currentPage == .healthGoal
    }
    
    /// 是否是最后一页
    var isLastPage: Bool {
        currentPage == .bodyMeasurement
    }
    
    /// 是否可以继续下一页
    var canProceed: Bool {
        switch currentPage {
        case .nickname:
            return !userProfile.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .gender:
            return true // 已有默认值
        case .birthYear:
            return userProfile.birthYear >= 1900 && userProfile.birthYear <= Calendar.current.component(.year, from: Date())
        case .bodyMeasurement:
            return userProfile.heightCm >= 50 && userProfile.heightCm <= 300 &&
                   userProfile.weightKg >= 10 && userProfile.weightKg <= 500
        case .activityLevel:
            return true // 已有默认值
        case .healthGoal:
            return true // 已有默认值
        }
    }
    
    // MARK: - Dependencies
    
    private let userProfileService = UserProfileService.shared
    private let authManager = AuthenticationManager.shared
    
    // MARK: - 完成回调
    var onComplete: (() -> Void)?
    
    // MARK: - Initialization
    
    init() {
        let userId = AuthenticationManager.shared.userIdentifier
        self.userProfile = UserProfile.empty(userId: userId)
    }
    
    // MARK: - Navigation Methods
    
    /// 前往下一页
    func nextPage() {
        guard canProceed else { return }
        
        if let next = OnboardingPage(rawValue: currentPage.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage = next
            }
        }
    }
    
    /// 返回上一页
    func previousPage() {
        if let previous = OnboardingPage(rawValue: currentPage.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage = previous
            }
        }
    }
    
    /// 跳转到指定页面
    func goToPage(_ page: OnboardingPage) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = page
        }
    }
    
    // MARK: - Data Submission
    
    /// 提交用户资料
    func submitProfile() async {
        guard canProceed else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        // 确保 userId 是最新的
        userProfile.userId = authManager.userIdentifier
        
        do {
            // 调用 API 保存用户资料
            _ = try await userProfileService.saveProfile(userProfile)
            
            // 标记 Onboarding 完成
            authManager.hasCompletedOnboarding = true
            
            // 通知完成
            onComplete?()
            
        } catch {
            // 检查是否是网络权限错误，如果是则自动重试一次
            if NetworkPermissionManager.isNetworkPermissionError(error) {
                print("⚠️ [OnboardingViewModel] 检测到网络权限错误，1.5秒后自动重试...")
                
                // 等待 1.5 秒后重试（给用户时间点击权限弹窗）
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                do {
                    _ = try await userProfileService.saveProfile(userProfile)
                    
                    // 重试成功
                    authManager.hasCompletedOnboarding = true
                    onComplete?()
                    isSubmitting = false
                    return
                    
                } catch {
                    // 重试也失败，显示引导用户开启权限的提示
                    if NetworkPermissionManager.isNetworkPermissionError(error) {
                        errorMessage = NetworkPermissionManager.getPermissionErrorMessage()
                    } else {
                        errorMessage = "保存失败，请稍后重试"
                    }
                    showError = true
                    print("❌ [OnboardingViewModel] 重试保存用户资料仍然失败: \(error)")
                }
            } else {
                errorMessage = "保存失败，请稍后重试"
                showError = true
                print("❌ [OnboardingViewModel] 保存用户资料失败: \(error)")
            }
        }
        
        isSubmitting = false
    }
    
    // MARK: - Validation Helpers
    
    /// 验证昵称
    func validateNickname(_ nickname: String) -> Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 20
    }
    
    /// 获取年龄显示文本
    func getAgeDisplayText() -> String {
        let age = userProfile.age
        if age < 0 || age > 150 {
            return "请选择有效的出生年份"
        }
        return "你今年 \(age) 岁"
    }
    
    /// 获取 BMI 显示文本
    func getBMIDisplayText() -> String {
        let bmi = userProfile.bmi
        return String(format: "BMI: %.1f (%@)", bmi, userProfile.bmiDescription)
    }
}
