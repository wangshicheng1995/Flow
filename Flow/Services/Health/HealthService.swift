//
//  HealthService.swift
//  Flow
//
//  Health（健康）模块的 API 服务
//  负责处理与健康数据相关的网络请求
//

import Foundation

/// Health 服务
/// 负责获取健康相关的数据（压力分数等）
final class HealthService {
    static let shared = HealthService()
    
    private init() {}
    
    // MARK: - 压力分数
    
    /// 获取压力分数
    /// - Returns: 压力分数数据
    func fetchStressScore() async throws -> StressScore {
        guard let url = HealthEndpoints.stressScore.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HealthEndpoints.stressScore.method
        request.timeoutInterval = APIConfig.timeout
        
        if APIConfig.enableDebugLog {
            print("🏥 [HealthService] 请求压力分数: \(url.absoluteString)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
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
