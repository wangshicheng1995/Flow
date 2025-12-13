//
//  APIConfig.swift
//  Flow
//
//  Created on 2025-12-13.
//

import Foundation

/// API 全局配置
enum APIConfig {
    /// 后端服务基础 URL
    static let baseURL = "http://139.196.221.226:8080"
    
    /// 请求超时时间（秒）
    static let timeout: TimeInterval = 30
    
    /// 是否启用调试日志
    static let enableDebugLog = true
}
