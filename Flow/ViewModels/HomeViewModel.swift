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
    var healthCoins: Int = 1250
    var selectedPhotoItem: PhotosPickerItem?
    var showCamera: Bool = false
    var showHistory: Bool = false
    var capturedImage: UIImage?
    var showPermissionAlert: Bool = false

    let cameraManager = CameraManager()

    // 计算健康货币的进度（假设最大值为 2000）
    var healthProgress: Double {
        Double(healthCoins) / 2000.0
    }

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

        // TODO: 处理拍摄的图片，进行食物识别
        print("已拍摄照片，尺寸: \(image.size)")
    }

    // 显示历史记录
    func showHistoryView() {
        showHistory = true
    }

    // 计算今日总健康货币（可以从数据库查询）
    func calculateDailyCoins() -> Int {
        // TODO: 从 SwiftData 查询今日记录并计算
        return healthCoins
    }
}
