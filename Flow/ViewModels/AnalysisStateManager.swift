//
//  AnalysisStateManager.swift
//  Flow
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftUI

// MARK: - 分析状态管理器
@Observable
final class AnalysisStateManager {
    static let shared = AnalysisStateManager()

    var latestAnalysisData: FoodAnalysisData?
    var latestCapturedImage: UIImage?
    var hasNewResult: Bool = false

    private init() {}

    // 更新最新的分析结果
    func updateAnalysisResult(data: FoodAnalysisData, image: UIImage) {
        latestAnalysisData = data
        latestCapturedImage = image
        hasNewResult = true
    }

    // 标记结果已查看
    func markAsViewed() {
        hasNewResult = false
    }
}
