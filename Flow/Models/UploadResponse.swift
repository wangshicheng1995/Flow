//
//  UploadResponse.swift
//  Flow
//
//  Upload 接口新响应结构
//  包含同步返回的分析结果和异步任务 ID 映射
//
//  Created on 2025-12-28.
//

import Foundation

// MARK: - Upload 响应结构

/// Upload 接口响应
/// 新结构：包含 analysisResult + asyncTasks + mealRecordId
struct UploadResponse: Codable {
    let code: Int
    let message: String
    let data: UploadResponseData?
}

/// Upload 响应数据
struct UploadResponseData: Codable {
    /// 同步返回的食物分析结果
    let analysisResult: FoodAnalysisData
    
    /// 异步任务 ID 映射
    /// Key: 任务类型标识（如 "glucoseTrend", "eatingOrder"）
    /// Value: 任务 UUID
    let asyncTasks: [String: String]?
    
    /// 餐食记录 ID
    let mealRecordId: Int?
    
    // MARK: - 便捷方法
    
    /// 获取血糖趋势任务 ID
    var glucoseTrendTaskId: String? {
        asyncTasks?["glucoseTrend"]
    }
    
    /// 获取吃饭顺序建议任务 ID
    var eatingOrderTaskId: String? {
        asyncTasks?["eatingOrder"]
    }
    
    /// 是否有异步任务需要轮询
    var hasAsyncTasks: Bool {
        guard let tasks = asyncTasks else { return false }
        return !tasks.isEmpty
    }
}

// MARK: - 兼容性扩展

extension UploadResponseData {
    /// 将异步任务 ID 列表转换为数组
    var allTaskIds: [String] {
        asyncTasks?.values.map { $0 } ?? []
    }
}
