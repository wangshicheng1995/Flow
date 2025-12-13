//
//  FlowService.swift
//  Flow
//
//  Created on 2025-11-30.
//

import Foundation

/// Flow 后端服务
/// 负责与 FlowService 后端 API 通信
final class FlowService {
    static let shared = FlowService()

    private init() {}

    // MARK: - 首页聚合数据接口

    /// 获取首页仪表盘聚合数据
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - date: 日期（yyyy-MM-dd 格式）
    /// - Returns: 首页聚合数据
    func fetchHomeDashboard(userId: String, date: String) async throws -> HomeDashboard {
        guard let url = APIEndpoints.homeDashboard(userId: userId, date: date).url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = APIConfig.timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200 ..< 300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(HomeDashboardResponse.self, from: data)

            guard apiResponse.code == 200, let dashboard = apiResponse.data else {
                throw APIError.serverError(apiResponse.message)
            }

            return dashboard
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - 压力分数接口（保留用于其他页面可能的单独调用）

    func fetchStressScore() async throws -> StressScore {
        guard let url = APIEndpoints.stressScore.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = APIEndpoints.stressScore.method
        request.timeoutInterval = APIConfig.timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200 ..< 300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(StressScore.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
