//
//  UserEndpoints.swift
//  Flow
//
//  用户相关 API 端点定义
//  Created on 2025-12-28.
//

import Foundation

/// 用户模块 API 端点
enum UserEndpoints {
    /// 获取用户资料
    case getProfile(userId: String)
    /// 保存/更新用户资料
    case saveProfile
    
    var path: String {
        switch self {
        case .getProfile(let userId):
            return "/api/user/profile/\(userId)"
        case .saveProfile:
            return "/api/user/profile"
        }
    }
    
    var method: String {
        switch self {
        case .getProfile:
            return "GET"
        case .saveProfile:
            return "POST"
        }
    }
    
    var url: URL? {
        return URL(string: APIConfig.baseURL + path)
    }
}
