//
//  RecordEndpoints.swift
//  Flow
//
//  Record（记录）模块的 API 端点定义
//

import Foundation

/// Record 模块 API 端点
enum RecordEndpoints {
    
    /// 图片上传分析接口
    case uploadImage
    
    /// 查询单个异步任务状态
    case taskStatus(taskId: String)
    
    /// 批量查询异步任务状态
    case batchTaskStatus(taskIds: [String])
    
    // MARK: - 接口路径
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/api/record/upload"
        case .taskStatus(let taskId):
            return "/api/task/\(taskId)"
        case .batchTaskStatus(let taskIds):
            let idsString = taskIds.joined(separator: ",")
            return "/api/task/batch?taskIds=\(idsString)"
        }
    }
    
    // MARK: - 请求方式
    
    var method: String {
        switch self {
        case .uploadImage:
            return "POST"
        case .taskStatus, .batchTaskStatus:
            return "GET"
        }
    }
    
    // MARK: - 完整 URL
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
}
