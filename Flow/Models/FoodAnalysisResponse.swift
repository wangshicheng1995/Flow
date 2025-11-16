//
//  FoodAnalysisResponse.swift
//  Flow
//
//  Created on 2025-11-05.
//

import Foundation

// MARK: - API 响应模型
struct FoodAnalysisResponse: Codable {
    let code: Int
    let message: String
    let data: FoodAnalysisData?
}

struct FoodAnalysisData: Codable {
    let taskId: String
    let originalPrompt: String
    let processedText: String  // 用户看的内容

    // 以下字段用于调试，可选
    let summary: String?
    let metadata: Metadata?
    let processedAt: String?

    struct Metadata: Codable {
        let fileName: String?
        let mimeType: String?
        let fileSize: Int?
        let model: String?
        let tokensUsed: Int?
        let processingTimeMs: Int?
    }
}
