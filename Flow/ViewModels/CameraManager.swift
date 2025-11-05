//
//  CameraManager.swift
//  Flow
//
//  Created on 2025-11-05.
//

import AVFoundation
import SwiftUI

@Observable
final class CameraManager {
    var authorizationStatus: AVAuthorizationStatus = .notDetermined

    init() {
        checkAuthorizationStatus()
    }

    // 检查当前相机权限状态
    func checkAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    // 请求相机权限
    func requestCameraPermission() async -> Bool {
        // 如果已经有权限，直接返回
        if authorizationStatus == .authorized {
            return true
        }

        // 如果被拒绝，返回 false（由调用方处理提示）
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            return false
        }

        // 请求权限
        let granted = await AVCaptureDevice.requestAccess(for: .video)

        await MainActor.run {
            checkAuthorizationStatus()
        }

        return granted
    }

    // 打开系统设置
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
