//
//  HomeService.swift
//  Flow
//
//  首页（Home）模块的 API 服务
//  负责处理与首页相关的所有网络请求
//

import Foundation

/// 首页服务
/// 负责获取首页仪表盘数据
final class HomeService {
    static let shared = HomeService()
    
    private init() {}
    
    // MARK: - 首页仪表盘数据
    
    /// 获取首页仪表盘聚合数据
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - date: 日期（yyyy-MM-dd 格式）
    /// - Returns: 首页聚合数据
    func fetchDashboard(userId: String, date: String) async throws -> HomeDashboard {
        guard let url = HomeEndpoints.dashboard(userId: userId, date: date).url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HomeEndpoints.dashboard(userId: userId, date: date).method
        request.timeoutInterval = APIConfig.timeout
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
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
}
