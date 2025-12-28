//
//  SummaryService.swift
//  Flow
//
//  Summary（概览）模块的 API 服务
//  负责处理与概览页面相关的所有网络请求
//
//  包含的接口：
//  - /calories/daily : 每日卡路里数据
//

import Foundation

// MARK: - Models

/// 每日卡路里数据
struct DailyCalorie: Codable, Identifiable {
    /// 日期（yyyy-MM-dd 格式）
    let date: String
    
    /// 当日总卡路里
    let calories: Int
    
    /// 当日餐食记录数量
    let mealCount: Int
    
    /// 用于 SwiftUI 列表的唯一标识符
    var id: String { date }
}

/// 每日卡路里 API 响应包装
struct DailyCalorieResponse: Codable {
    let code: Int
    let message: String
    let data: [DailyCalorie]?
}

// MARK: - Service

/// Summary 服务
/// 负责获取概览页面所需的数据
final class SummaryService {
    static let shared = SummaryService()
    
    private init() {}
    
    // MARK: - 每日卡路里数据
    
    /// 获取最近 7 天的每日卡路里数据
    /// - Parameter userId: 用户 ID
    /// - Returns: 每日卡路里数据数组（按日期排序）
    func fetchDailyCalories(userId: String) async throws -> [DailyCalorie] {
        guard let url = SummaryEndpoints.dailyCalories(userId: userId).url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = SummaryEndpoints.dailyCalories(userId: userId).method
        request.timeoutInterval = APIConfig.timeout
        
        if APIConfig.enableDebugLog {
            print("📊 [SummaryService] 请求每日卡路里数据: \(url.absoluteString)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }
            
            if APIConfig.enableDebugLog, let jsonString = String(data: data, encoding: .utf8) {
                print("📊 [SummaryService] 响应数据: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(DailyCalorieResponse.self, from: data)
            
            guard apiResponse.code == 200, let dailyCalories = apiResponse.data else {
                throw APIError.serverError(apiResponse.message)
            }
            
            if APIConfig.enableDebugLog {
                print("📊 [SummaryService] 获取到 \(dailyCalories.count) 天的数据")
            }
            
            return dailyCalories
        } catch let error as DecodingError {
            if APIConfig.enableDebugLog {
                print("❌ [SummaryService] 解析错误: \(error)")
            }
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
