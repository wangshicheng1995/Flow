//
//  APIError.swift
//  Flow
//
//  API 错误类型定义
//  统一管理所有网络请求可能产生的错误
//

import Foundation

/// API 错误枚举
/// 包含所有可能的网络请求错误类型
enum APIError: Error {
    /// 无效的 URL
    case invalidURL
    
    /// 无效的响应
    case invalidResponse
    
    /// 网络错误
    case networkError(Error)
    
    /// 服务器错误
    case serverError(String)
    
    /// 数据解析错误
    case decodingError(Error)
    
    /// 用户友好的错误描述
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(let message):
            return "服务器错误: \(message)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        }
    }
}
