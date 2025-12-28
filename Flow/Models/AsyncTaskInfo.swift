//
//  AsyncTaskInfo.swift
//  Flow
//
//  异步任务信息模型
//  用于存储和追踪异步 AI 分析任务的状态
//
//  Created on 2025-12-28.
//

import Foundation

// MARK: - 任务状态枚举

/// 异步任务执行状态
enum AsyncTaskStatus: String, Codable {
    /// 等待执行
    case pending = "PENDING"
    /// 执行中
    case running = "RUNNING"
    /// 已完成
    case completed = "COMPLETED"
    /// 执行失败
    case failed = "FAILED"
    /// 已取消
    case cancelled = "CANCELLED"
}

// MARK: - 任务类型枚举

/// 异步任务类型
enum AsyncTaskType: String, Codable {
    /// 血糖趋势预测
    case glucoseTrend = "GLUCOSE_TREND"
    /// 吃饭顺序建议
    case eatingOrder = "EATING_ORDER"
    /// 健康评分分析（预留）
    case healthScore = "HEALTH_SCORE"
}

// MARK: - 任务信息模型

/// 异步任务信息
struct AsyncTaskInfo: Codable {
    /// 任务唯一标识
    let taskId: String
    /// 任务类型
    let taskType: AsyncTaskType
    /// 任务状态
    let status: AsyncTaskStatus
    /// 任务创建时间
    let createdAt: String?
    /// 任务完成时间
    let completedAt: String?
    /// 错误信息（仅当 status == .failed 时有值）
    let errorMessage: String?
}

// MARK: - 任务查询响应

/// 单个任务查询响应
struct AsyncTaskResponse: Codable {
    let code: Int
    let message: String
    let data: AsyncTaskResultData?
}

/// 任务结果数据（通用包装）
struct AsyncTaskResultData: Codable {
    let taskId: String
    let taskType: String
    let status: String
    let result: TaskResultPayload?
    let createdAt: String?
    let completedAt: String?
    let errorMessage: String?
    
    /// 获取解析后的任务状态
    var parsedStatus: AsyncTaskStatus {
        AsyncTaskStatus(rawValue: status) ?? .pending
    }
    
    /// 获取解析后的任务类型
    var parsedTaskType: AsyncTaskType? {
        AsyncTaskType(rawValue: taskType)
    }
}

/// 任务结果负载（根据任务类型解析）
struct TaskResultPayload: Codable {
    // 血糖趋势相关字段
    let peakValue: Double?
    let peakTime: String?
    let trendData: [Double]?
    
    // 吃饭顺序建议相关字段
    let title: String?
    let tips: [EatingTipResult]?
    let expectedImprovement: String?
}

/// 吃饭建议结果
struct EatingTipResult: Codable {
    let order: Int
    let title: String
    let description: String
    let relatedFoods: [String]?
}

// MARK: - 批量查询响应

/// 批量任务查询响应
struct BatchTaskResponse: Codable {
    let code: Int
    let message: String
    let data: [AsyncTaskResultData]?
}
