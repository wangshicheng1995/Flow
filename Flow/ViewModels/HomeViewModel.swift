//
//  HomeViewModel.swift
//  Flow
//
//  Created on 2025-11-05.
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
final class HomeViewModel {
    var selectedPhotoItem: PhotosPickerItem?
    var capturedImage: UIImage?
    var isAnalyzing: Bool = false
    var analysisResult: FoodAnalysisData?
    var showAnalysisResult: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var stressScoreRefresher: (() async -> Void)?

    let analysisService = RecordService.shared

    // 处理从相册选择的照片
    func handlePhotoSelection() async {
        guard let item = selectedPhotoItem else { return }

        do {
            // 从 PhotosPickerItem 加载图片数据
            guard let imageData = try await item.loadTransferable(type: Data.self) else {
                print("❌ 无法加载图片数据")
                selectedPhotoItem = nil
                return
            }

            // 转换为 UIImage
            guard let image = UIImage(data: imageData) else {
                print("❌ 无法转换图片数据")
                selectedPhotoItem = nil
                return
            }

            print("✅ 成功加载图库照片，尺寸: \(image.size)")

            // 重置选择
            selectedPhotoItem = nil

            // 调用图片分析流程（与拍照流程相同）
            capturedImage = image
            await analyzeImage(image)

        } catch {
            print("❌ 加载图库照片失败: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "加载照片失败，请重试"
                showError = true
            }
            selectedPhotoItem = nil
        }
    }

    // 处理拍摄的照片
    func handleCapturedImage(_ image: UIImage) {
        capturedImage = image

        // 开始分析图片
        Task {
            await analyzeImage(image)
        }
    }

    // 分析图片
    @MainActor
    func analyzeImage(_ image: UIImage) async {
        isAnalyzing = true
        errorMessage = nil

        do {
            print("开始上传图片到 API...")
            let result = try await analysisService.uploadImage(image)
            print("API 返回成功: \(result.foods.map { $0.name }.joined(separator: ", "))")

            analysisResult = result
            isAnalyzing = false
            showAnalysisResult = true

            if let refresher = stressScoreRefresher {
                Task {
                    await refresher()
                }
            }

        } catch let error as APIError {
            print("API 错误: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isAnalyzing = false
            showError = true

        } catch {
            print("未知错误: \(error.localizedDescription)")
            errorMessage = "图片分析失败，请重试"
            isAnalyzing = false
            showError = true
        }
    }

}
