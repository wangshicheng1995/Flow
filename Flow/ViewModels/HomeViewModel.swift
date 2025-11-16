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
    var showCamera: Bool = false
    var showHistory: Bool = false
    var capturedImage: UIImage?
    var showPermissionAlert: Bool = false
    var isAnalyzing: Bool = false
    var analysisResult: FoodAnalysisData?
    var showAnalysisResult: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    let cameraManager = CameraManager()
    let analysisService = FoodAnalysisService.shared

    // 处理从相册选择的照片
    func handlePhotoSelection() async {
        guard let item = selectedPhotoItem else { return }

        // 这里处理照片识别逻辑
        // TODO: 实现食物识别功能
        print("处理选中的照片: \(item)")

        // 重置选择
        selectedPhotoItem = nil
    }

    // 处理拍照按钮点击
    func handleCameraButtonTap() async {
        let hasPermission = await cameraManager.requestCameraPermission()

        if hasPermission {
            await MainActor.run {
                showCamera = true
            }
        } else if cameraManager.authorizationStatus == .denied || cameraManager.authorizationStatus == .restricted {
            await MainActor.run {
                showPermissionAlert = true
            }
        }
    }
    
    // 打开系统设置
    func openSettings() {
        cameraManager.openSettings()
    }

    // 处理拍摄的照片
    func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
        showCamera = false

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
            print("API 返回成功: \(result.processedText)")

            // 保存分析结果
            analysisResult = result
            isAnalyzing = false
            showAnalysisResult = true

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

    // 显示历史记录
    func showHistoryView() {
        showHistory = true
    }
}
