//
//  BannerManager.swift
//  Flow
//
//  Created on 2025-12-05.
//

import Foundation

/// 管理首页 Banner 图片的每日随机展示
class BannerManager: ObservableObject {
    static let shared = BannerManager()
    
    // MARK: - 调试开关
    /// 是否启用点击 banner 随机更换功能（仅调试用，上线前设为 false）
    static let enableTapToChangeBanner = true
    
    /// 可用的 banner 图片名称列表
    private let bannerNames = ["banner", "banner1", "banner3"]
    
    /// 当前应该展示的 banner 图片名称
    @Published var dailyBannerName: String
    
    private let lastDateKey = "BannerManager.lastDate"
    private let currentBannerKey = "BannerManager.currentBanner"
    
    private init() {
        dailyBannerName = BannerManager.loadOrSelectBanner(
            bannerNames: bannerNames,
            lastDateKey: lastDateKey,
            currentBannerKey: currentBannerKey
        )
    }
    
    /// 随机更换 banner（调试用）
    func randomizeBanner() {
        guard BannerManager.enableTapToChangeBanner else { return }
        
        // 从列表中随机选择一个不同的 banner
        var newBanner: String
        repeat {
            newBanner = bannerNames.randomElement() ?? "banner"
        } while newBanner == dailyBannerName && bannerNames.count > 1
        
        dailyBannerName = newBanner
        
        // 同时更新 UserDefaults，这样下次打开 App 也会显示新选择的 banner
        let defaults = UserDefaults.standard
        defaults.set(newBanner, forKey: currentBannerKey)
    }
    
    /// 加载今日的 banner，如果是新的一天则随机选择一个新的
    private static func loadOrSelectBanner(
        bannerNames: [String],
        lastDateKey: String,
        currentBannerKey: String
    ) -> String {
        let defaults = UserDefaults.standard
        let today = formattedDate(Date())
        
        // 检查是否是同一天
        if let lastDate = defaults.string(forKey: lastDateKey),
           lastDate == today,
           let savedBanner = defaults.string(forKey: currentBannerKey),
           bannerNames.contains(savedBanner) {
            // 同一天，返回已保存的 banner
            return savedBanner
        }
        
        // 新的一天，随机选择一个 banner
        let selectedBanner = bannerNames.randomElement() ?? "banner"
        
        // 保存选择结果
        defaults.set(today, forKey: lastDateKey)
        defaults.set(selectedBanner, forKey: currentBannerKey)
        
        return selectedBanner
    }
    
    /// 将日期格式化为 "yyyy-MM-dd" 字符串
    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
