//
//  AsyncTaskService.swift
//  Flow
//
//  异步任务查询服务
//  负责轮询异步任务状态并获取结果
//
//  Created on 2025-12-28.
//

import Foundation

/// 异步任务服务
/// 负责查询和轮询异步任务状态
final class AsyncTaskService {
    static let shared = AsyncTaskService()
    
    private init() {}
    
    // MARK: - 配置
    
    /// 轮询间隔（秒）
    private let pollingInterval: TimeInterval = 1.5
    /// 最大轮询次数
    private let maxPollingAttempts = 30
    
    // MARK: - 查询单个任务
    
    /// 查询单个异步任务状态
    /// - Parameter taskId: 任务 ID
    /// - Returns: 任务结果数据
    func fetchTaskStatus(taskId: String) async throws -> AsyncTaskResultData {
        guard let url = RecordEndpoints.taskStatus(taskId: taskId).url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RecordEndpoints.taskStatus(taskId: taskId).method
        request.timeoutInterval = APIConfig.timeout
        
        if APIConfig.enableDebugLog {
            print("🔄 [AsyncTaskService] 查询任务状态: \(taskId)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if APIConfig.enableDebugLog {
            print("🔄 [AsyncTaskService] 响应状态码: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(AsyncTaskResponse.self, from: data)
        
        if apiResponse.code != 200 {
            throw APIError.serverError(apiResponse.message)
        }
        
        guard let resultData = apiResponse.data else {
            throw APIError.serverError("任务数据为空")
        }
        
        return resultData
    }
    
    // MARK: - 轮询任务
    
    /// 轮询任务直到完成或超时
    /// - Parameters:
    ///   - taskId: 任务 ID
    ///   - onProgress: 进度回调（可选）
    /// - Returns: 完成的任务结果
    func pollTask(
        taskId: String,
        onProgress: ((AsyncTaskStatus) -> Void)? = nil
    ) async throws -> AsyncTaskResultData {
        var attempts = 0
        
        while attempts < maxPollingAttempts {
            attempts += 1
            
            do {
                let result = try await fetchTaskStatus(taskId: taskId)
                let status = result.parsedStatus
                
                onProgress?(status)
                
                if APIConfig.enableDebugLog {
                    print("🔄 [AsyncTaskService] 任务 \(taskId) 状态: \(status.rawValue) (尝试 \(attempts)/\(maxPollingAttempts))")
                }
                
                switch status {
                case .completed:
                    return result
                case .failed:
                    throw APIError.serverError(result.errorMessage ?? "任务执行失败")
                case .cancelled:
                    throw APIError.serverError("任务已取消")
                case .pending, .running:
                    // 继续轮询
                    try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
                }
            } catch let error as APIError {
                throw error
            } catch {
                // 网络错误时继续重试
                if attempts >= maxPollingAttempts {
                    throw APIError.networkError(error)
                }
                try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
            }
        }
        
        throw APIError.serverError("任务轮询超时")
    }
    
    // MARK: - 批量查询
    
    /// 批量查询多个任务状态
    /// - Parameter taskIds: 任务 ID 列表
    /// - Returns: 任务结果列表
    func fetchBatchTaskStatus(taskIds: [String]) async throws -> [AsyncTaskResultData] {
        guard !taskIds.isEmpty else { return [] }
        
        guard let url = RecordEndpoints.batchTaskStatus(taskIds: taskIds).url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RecordEndpoints.batchTaskStatus(taskIds: taskIds).method
        request.timeoutInterval = APIConfig.timeout
        
        if APIConfig.enableDebugLog {
            print("🔄 [AsyncTaskService] 批量查询任务: \(taskIds)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if APIConfig.enableDebugLog {
            print("🔄 [AsyncTaskService] 批量响应状态码: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(BatchTaskResponse.self, from: data)
        
        if apiResponse.code != 200 {
            throw APIError.serverError(apiResponse.message)
        }
        
        return apiResponse.data ?? []
    }
    
    // MARK: - 便捷方法
    
    /// 轮询血糖趋势任务并转换为 GlucoseTrendData
    func pollGlucoseTrendTask(taskId: String) async throws -> GlucoseTrendData? {
        let result = try await pollTask(taskId: taskId)
        
        guard let payload = result.result else { return nil }
        
        // 将 TaskResultPayload 转换为 GlucoseTrendData
        // 注意：后续需要根据实际 API 返回结构调整
        return GlucoseTrendData(
            timePoints: [0, 15, 30, 45, 60, 90, 120],
            glucoseValues: payload.trendData ?? [95, 125, 148, 138, 118, 102, 94],
            peakValue: payload.peakValue ?? 148,
            peakTimeMinutes: 30,
            impactLevel: "MEDIUM",
            recoveryTimeMinutes: 110,
            normalRangeLow: 70,
            normalRangeHigh: 140
        )
    }
    
    /// 轮询吃饭顺序建议任务并转换为 EatingTipsData
    func pollEatingOrderTask(taskId: String) async throws -> EatingTipsData? {
        let result = try await pollTask(taskId: taskId)
        
        guard let payload = result.result else { return nil }
        
        // 将 TaskResultPayload 转换为 EatingTipsData
        let tips = payload.tips?.map { tip in
            EatingTip(
                order: tip.order,
                iconName: "fork.knife",
                title: tip.title,
                description: tip.description,
                relatedFoods: tip.relatedFoods
            )
        } ?? []
        
        return EatingTipsData(
            title: payload.title ?? "调整进食顺序可降低血糖峰值",
            tips: tips,
            expectedImprovement: payload.expectedImprovement
        )
    }
}
