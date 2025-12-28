//
//  SummaryViewModel.swift
//  Flow
//
//  Summary（概览）页面的 ViewModel
//  负责管理页面所有数据的加载和状态
//

import Foundation

@MainActor
final class SummaryViewModel: ObservableObject {
    
    // MARK: - Published 属性
    
    /// 每日卡路里数据（最近 7 天）
    @Published var dailyCalories: [DailyCalorie] = []
    
    /// 是否正在加载
    @Published var isLoading: Bool = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 数据是否已加载过
    @Published var hasLoadedOnce: Bool = false
    
    // MARK: - 计算属性
    
    /// 柱状图数据（卡路里值数组）
    var barChartData: [CGFloat] {
        dailyCalories.map { CGFloat($0.calories) }
    }
    
    /// 今日总卡路里（最后一天的数据）
    var todayCalories: Int {
        dailyCalories.last?.calories ?? 0
    }
    
    /// 今日餐食数量
    var todayMealCount: Int {
        dailyCalories.last?.mealCount ?? 0
    }
    
    // MARK: - 公开方法
    
    /// 加载所有数据
    func loadAllData() async {
        isLoading = true
        errorMessage = nil
        
        await loadDailyCalories()
        
        isLoading = false
        hasLoadedOnce = true
    }
    
    // MARK: - 私有方法
    
    /// 加载每日卡路里数据
    private func loadDailyCalories() async {
        do {
            let userId = AuthenticationManager.shared.userIdentifier
            let data = try await SummaryService.shared.fetchDailyCalories(userId: userId)
            dailyCalories = data
            
            if APIConfig.enableDebugLog {
                print("✅ [SummaryViewModel] 加载成功，获取到 \(data.count) 天的数据")
                if let last = data.last {
                    print("✅ [SummaryViewModel] 今日数据: 日期=\(last.date), 卡路里=\(last.calories), 餐数=\(last.mealCount)")
                } else {
                    print("⚠️ [SummaryViewModel] 数据数组为空")
                }
            }
        } catch {
            errorMessage = "数据加载失败，请下拉刷新"
            if APIConfig.enableDebugLog {
                print("❌ [SummaryViewModel] 加载失败: \(error)")
            }
        }
    }
}
