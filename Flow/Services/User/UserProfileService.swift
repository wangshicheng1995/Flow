//
//  UserProfileService.swift
//  Flow
//
//  用户资料服务 - 处理用户资料的获取和保存
//  Created on 2025-12-28.
//

import Foundation

/// 用户资料服务
final class UserProfileService {
    static let shared = UserProfileService()
    
    private init() {}
    
    // MARK: - 获取用户资料
    
    /// 获取用户资料
    /// - Parameter userId: 用户 ID
    /// - Returns: 用户资料（如果存在）
    /// - Throws: APIError
    func fetchProfile(userId: String) async throws -> UserProfile? {
        guard let url = UserEndpoints.getProfile(userId: userId).url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = UserEndpoints.getProfile(userId: userId).method
        request.timeoutInterval = APIConfig.timeout
        
        if APIConfig.enableDebugLog {
            print("📤 [UserProfileService] 获取用户资料: \(userId)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if APIConfig.enableDebugLog {
                print("📥 [UserProfileService] 响应状态码: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [UserProfileService] 响应数据: \(jsonString)")
                }
            }
            
            // 404 表示用户不存在（新用户）
            if httpResponse.statusCode == 404 {
                return nil
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(UserProfileResponse.self, from: data)
            
            guard apiResponse.code == 200 else {
                throw APIError.serverError(apiResponse.message)
            }
            
            return apiResponse.data
            
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - 保存用户资料
    
    /// 保存用户资料
    /// - Parameter profile: 用户资料
    /// - Returns: 保存后的用户资料
    /// - Throws: APIError
    func saveProfile(_ profile: UserProfile) async throws -> UserProfile {
        guard let url = UserEndpoints.saveProfile.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = UserEndpoints.saveProfile.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = APIConfig.timeout
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(profile)
        
        if APIConfig.enableDebugLog {
            print("📤 [UserProfileService] 保存用户资料: \(profile.nickname)")
            if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("📤 [UserProfileService] 请求数据: \(bodyString)")
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if APIConfig.enableDebugLog {
                print("📥 [UserProfileService] 响应状态码: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [UserProfileService] 响应数据: \(jsonString)")
                }
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(UserProfileResponse.self, from: data)
            
            guard apiResponse.code == 200, let savedProfile = apiResponse.data else {
                throw APIError.serverError(apiResponse.message)
            }
            
            return savedProfile
            
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - 检查用户是否存在
    
    /// 检查用户是否已完成 Onboarding
    /// - Parameter userId: 用户 ID
    /// - Returns: true 表示已存在，false 表示新用户
    func checkUserExists(userId: String) async -> Bool {
        do {
            let profile = try await fetchProfile(userId: userId)
            return profile != nil
        } catch {
            if APIConfig.enableDebugLog {
                print("⚠️ [UserProfileService] 检查用户存在性失败: \(error)")
            }
            // 网络错误时返回 false，让用户走一遍 Onboarding 流程
            // 后端会通过 userId 进行 upsert，不会产生重复数据
            return false
        }
    }
}
