//
//  RecordService.swift
//  Flow
//
//  Record（记录）模块的 API 服务
//  负责处理与食物记录相关的所有网络请求
//

import Foundation
import UIKit

/// Record 服务
/// 负责处理食物图片上传和分析
final class RecordService {
    static let shared = RecordService()
    
    private init() {}
    
    // MARK: - 图片上传分析（新版 - 支持异步任务）
    
    /// 上传图片并获取食物分析结果（新版）
    /// 返回包含同步分析结果和异步任务 ID 的完整响应
    /// - Parameter image: 待分析的食物图片
    /// - Returns: 上传响应数据（包含 analysisResult 和 asyncTasks）
    func uploadImageV2(_ image: UIImage) async throws -> UploadResponseData {
        guard let url = RecordEndpoints.uploadImage.url else {
            throw APIError.invalidURL
        }
        
        // 获取当前用户 ID
        let userId = AuthenticationManager.shared.userIdentifier
        if APIConfig.enableDebugLog {
            print("📤 [RecordService] 上传图片 V2，userId: \(userId)")
        }
        
        // 压缩图片为 JPEG 格式
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidResponse
        }
        
        // 生成唯一的文件名（使用时间戳）
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let filename = "food_\(timestamp).jpg"
        
        // 创建 multipart/form-data 请求
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = RecordEndpoints.uploadImage.method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = APIConfig.timeout
        
        // 构建 multipart body
        let httpBody = createMultipartBody(
            boundary: boundary,
            userId: userId,
            imageData: imageData,
            mimeType: "image/jpeg",
            filename: filename
        )
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if APIConfig.enableDebugLog {
                print("📤 [RecordService] V2 响应状态码: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📤 [RecordService] V2 响应数据: \(jsonString)")
                }
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(UploadResponse.self, from: data)
            
            if apiResponse.code != 200 {
                throw APIError.serverError(apiResponse.message)
            }
            
            guard let responseData = apiResponse.data else {
                throw APIError.serverError("未返回分析数据")
            }
            
            // 发送上传成功通知
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUploadFood, object: nil)
            }
            
            return responseData
            
        } catch let error as DecodingError {
            // 如果新格式解析失败，尝试兼容旧格式
            if APIConfig.enableDebugLog {
                print("📤 [RecordService] V2 解析失败，尝试兼容旧格式: \(error)")
            }
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - 图片上传分析（简化版）
    
    /// 上传图片并获取食物分析结果
    /// - Parameter image: 待分析的食物图片
    /// - Returns: 食物分析数据
    func uploadImage(_ image: UIImage) async throws -> FoodAnalysisData {
        let responseData = try await uploadImageV2(image)
        return responseData.analysisResult
    }
    
    // MARK: - Private Methods
    
    /// 创建 multipart/form-data body
    private func createMultipartBody(
        boundary: String,
        userId: String,
        imageData: Data,
        mimeType: String,
        filename: String
    ) -> Data {
        var body = Data()
        
        // 添加 userId 字段
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n")
        body.append("\(userId)\r\n")
        
        // 添加文件字段
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        // 结束标记
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}

// MARK: - Data Extension
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
