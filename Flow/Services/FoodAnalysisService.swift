//
//  FoodAnalysisService.swift
//  Flow
//
//  Created on 2025-11-05.
//

import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    case decodingError(Error)

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

final class FoodAnalysisService {
    static let shared = FoodAnalysisService()

    private let baseURL = "http://139.196.221.226:8080"
    private let uploadEndpoint = "/api/image/upload"

    private init() {}

    // 上传图片并获取分析结果
    func uploadImage(_ image: UIImage) async throws -> FoodAnalysisData {
        // 构建 URL
        guard let url = URL(string: baseURL + uploadEndpoint) else {
            throw APIError.invalidURL
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
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // 构建 multipart body
        let httpBody = createMultipartBody(
            boundary: boundary,
            data: imageData,
            mimeType: "image/jpeg",
            filename: filename
        )
        request.httpBody = httpBody

        // 发送请求
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 检查响应状态码
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("API 响应状态码: \(httpResponse.statusCode)")

            // 打印原始响应数据（调试用）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API 原始响应: \(jsonString)")
            }

            // 解析响应（支持 snake_case 和 camelCase）
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(FoodAnalysisResponse.self, from: data)

            // 检查业务状态码
            if apiResponse.code != 200 {
                throw APIError.serverError(apiResponse.message)
            }

            guard let analysisData = apiResponse.data else {
                throw APIError.serverError("未返回分析数据")
            }

            // 打印调试信息
            print("📊 分析结果: 食物=\(analysisData.foodItemsText), 置信度=\(analysisData.confidence), 营养均衡=\(analysisData.isBalanced)")

            return analysisData

        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // 创建 multipart/form-data body
    private func createMultipartBody(
        boundary: String,
        data: Data,
        mimeType: String,
        filename: String
    ) -> Data {
        var body = Data()

        // 添加文件字段
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
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
