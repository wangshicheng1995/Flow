//
//  HomeDataViewModel.swift
//  Flow
//
//  Created on 2025-12-13.
//

import Foundation
import Combine

/// 首页数据 ViewModel
/// 统一管理首页所有需要从后端获取的数据
@MainActor
final class HomeDataViewModel: ObservableObject {
    
    // MARK: - Published 属性（驱动 UI 更新）
    
    /// 压力/健康评分
    @Published var stressScore: Int = 40
    
    /// 今日总热量
    @Published var totalCalories: Int = 0
    
    /// 今日餐食记录数量
    @Published var mealCount: Int = 0
    
    /// 优质蛋白摄入量（克）- 后端暂未实现
    @Published var proteinQuality: Double = 0
    
    /// 糖负荷指数 - 后端暂未实现
    @Published var glycemicLoad: Double = 0
    
    /// 是否正在加载
    @Published var isLoading: Bool = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 数据是否已加载过
    @Published var hasLoadedOnce: Bool = false
    
    // MARK: - 私有属性
    
    private let flowService: FlowService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    init(flowService: FlowService = .shared) {
        self.flowService = flowService
        setupNotificationObservers()
    }
    
    // MARK: - 设置通知监听
    
    private func setupNotificationObservers() {
        // 监听食物上传成功通知
        NotificationCenter.default.publisher(for: .didUploadFood)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadAllData()
                }
            }
            .store(in: &cancellables)
        
        // 监听食物记录删除通知
        NotificationCenter.default.publisher(for: .didDeleteFoodRecord)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadAllData()
                }
            }
            .store(in: &cancellables)
        
        // 监听主动刷新请求
        NotificationCenter.default.publisher(for: .shouldRefreshHomeData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 公开方法
    
    /// 加载所有首页数据
    /// 使用聚合接口一次性获取所有数据
    func loadAllData() async {
        isLoading = true
        errorMessage = nil
        
        await loadDashboardData()
        
        isLoading = false
        hasLoadedOnce = true
    }
    
    // MARK: - 私有方法
    
    /// 获取当前日期字符串（yyyy-MM-dd 格式）
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// 加载聚合数据（单一接口）
    private func loadDashboardData() async {
        do {
            let userId = AuthenticationManager.shared.userIdentifier
            let date = getCurrentDateString()
            let dashboard = try await flowService.fetchHomeDashboard(userId: userId, date: date)
            
            // 更新所有数据
            if let score = dashboard.stressScore {
                stressScore = score
            }
            if let calories = dashboard.totalCalories {
                totalCalories = calories
            }
            if let count = dashboard.mealCount {
                mealCount = count
            }
            // 优质蛋白和糖负荷 - 后端暂未返回，使用默认值
            if let protein = dashboard.proteinQuality {
                proteinQuality = protein
            }
            if let glycemic = dashboard.glycemicLoad {
                glycemicLoad = glycemic
            }
            
            if APIConfig.enableDebugLog {
                print("✅ Dashboard 数据加载成功: stressScore=\(stressScore), calories=\(totalCalories), mealCount=\(mealCount)")
            }
        } catch {
            errorMessage = "数据加载失败，请下拉刷新"
            if APIConfig.enableDebugLog {
                print("❌ Dashboard 加载失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 格式化辅助方法

extension HomeDataViewModel {
    /// 格式化热量显示
    var formattedCalories: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalCalories)) ?? "\(totalCalories)"
    }
    
    /// 格式化蛋白质显示
    var formattedProtein: String {
        return String(format: "%.0f", proteinQuality)
    }
    
    /// 格式化糖负荷显示
    var formattedGlycemicLoad: String {
        return String(format: "%.0f", glycemicLoad)
    }
    
    /// 格式化餐食数量显示
    var formattedMealCount: String {
        return "\(mealCount)"
    }
}
