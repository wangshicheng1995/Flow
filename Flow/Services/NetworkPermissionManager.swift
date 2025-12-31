//
//  NetworkPermissionManager.swift
//  Flow
//
//  网络权限管理器 - 处理中国大陆地区 iOS 设备特有的网络权限弹窗问题
//  使用 CoreTelephony 框架监听网络权限状态变化
//  Created on 2025-12-30.
//

import Foundation
import CoreTelephony
import Combine

/// 网络权限状态
enum NetworkPermissionState {
    case unknown        // 未知状态（首次安装或等待用户授权）
    case restricted     // 用户拒绝了网络权限
    case notRestricted  // 权限正常
}

/// 网络权限管理器
/// 用于处理中国大陆地区 iOS 设备特有的"无线数据"权限弹窗问题
///
/// 重要说明：
/// - 在中国大陆 iOS 设备上，CTCellularData.restrictedState 可能在用户看到弹窗之前就返回 .restricted
/// - 这不代表用户真的拒绝了，只是系统默认状态
/// - 必须先发起网络请求触发弹窗，然后通过回调监听用户的真实选择
@MainActor
class NetworkPermissionManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = NetworkPermissionManager()
    
    // MARK: - Published Properties
    
    /// 当前权限状态（只有通过回调确认的才是真实状态）
    @Published private(set) var permissionState: NetworkPermissionState = .unknown
    
    /// 是否正在等待用户授权
    @Published private(set) var isWaitingForPermission: Bool = false
    
    /// 权限是否已确认获得（通过回调确认）
    @Published private(set) var isPermissionGranted: Bool = false
    
    /// 用户是否明确拒绝了权限（通过回调确认）
    @Published private(set) var isPermissionDenied: Bool = false
    
    // MARK: - Private Properties
    
    private let cellularData = CTCellularData()
    private var hasTriggeredPrompt = false
    private var hasReceivedCallback = false  // 是否已收到回调
    
    // MARK: - Initialization
    
    private init() {
        setupNotifier()
    }
    
    // MARK: - Public Methods
    
    /// 开始监听并触发权限弹窗
    /// 应在 App 启动时（如 SplashView 显示期间）调用
    ///
    /// 重要：无论初始状态是什么，都会触发诱饵请求来触发系统弹窗
    func checkAndTriggerIfNeeded() {
        print("📡 [NetworkPermissionManager] 开始检查网络权限...")
        
        // 获取当前状态（仅用于日志，不作为判断依据）
        let initialState = cellularData.restrictedState
        print("📡 [NetworkPermissionManager] 初始状态: \(stateDescription(initialState))")
        print("📡 [NetworkPermissionManager] 注意：初始状态不代表用户真实选择，将触发诱饵请求...")
        
        // 无论初始状态如何，都触发诱饵请求
        // 因为在中国大陆设备上，初始状态可能是 .restricted，但弹窗还没出现
        triggerSystemPrompt()
    }
    
    /// 触发系统权限弹窗
    /// 发起一个轻量级请求来触发系统的网络权限弹窗
    func triggerSystemPrompt() {
        guard !hasTriggeredPrompt else {
            print("📡 [NetworkPermissionManager] 已触发过权限弹窗，跳过")
            return
        }
        
        hasTriggeredPrompt = true
        isWaitingForPermission = true
        
        print("📡 [NetworkPermissionManager] 触发系统权限弹窗（发起诱饵请求）...")
        
        // 发起一个轻量级请求来触发系统弹窗
        // 使用 apple.com 作为目标，因为它稳定且全球可访问
        guard let url = URL(string: "https://www.apple.com") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] _, _, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    print("📡 [NetworkPermissionManager] 诱饵请求完成（可能失败）: \(error.localizedDescription)")
                    // 请求失败不代表用户拒绝，可能只是弹窗还没处理完
                    // 真实状态会通过 cellularDataRestrictionDidUpdateNotifier 回调获取
                } else {
                    print("📡 [NetworkPermissionManager] 诱饵请求成功，网络权限已获得")
                    self.permissionState = .notRestricted
                    self.isPermissionGranted = true
                    self.isWaitingForPermission = false
                    self.hasReceivedCallback = true
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func setupNotifier() {
        // 设置回调监听器
        // 这个回调会在用户真正点击弹窗后触发
        cellularData.cellularDataRestrictionDidUpdateNotifier = { [weak self] state in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.hasReceivedCallback = true
                self.isWaitingForPermission = false
                
                switch state {
                case .restrictedStateUnknown:
                    print("📡 [NetworkPermissionManager] 回调状态: 未知（等待用户授权）")
                    self.permissionState = .unknown
                    
                case .restricted:
                    print("📡 [NetworkPermissionManager] 回调状态: 用户拒绝了网络权限")
                    self.permissionState = .restricted
                    self.isPermissionGranted = false
                    self.isPermissionDenied = true
                    
                case .notRestricted:
                    print("📡 [NetworkPermissionManager] 回调状态: 用户允许了网络权限 ✅")
                    self.permissionState = .notRestricted
                    self.isPermissionGranted = true
                    self.isPermissionDenied = false
                    
                @unknown default:
                    print("📡 [NetworkPermissionManager] 回调状态: 未知的新状态")
                    break
                }
            }
        }
    }
    
    private func stateDescription(_ state: CTCellularDataRestrictedState) -> String {
        switch state {
        case .restrictedStateUnknown: return "未知"
        case .restricted: return "受限（可能是默认状态，不代表用户拒绝）"
        case .notRestricted: return "正常"
        @unknown default: return "未知的新状态"
        }
    }
}

// MARK: - Error Extension

extension NetworkPermissionManager {
    
    /// 检查错误是否是由于网络权限被拒绝导致的
    static func isNetworkPermissionError(_ error: Error) -> Bool {
        let nsError = error as NSError
        
        // 常见的网络权限相关错误码
        let permissionErrorCodes = [
            -1009,  // NSURLErrorNotConnectedToInternet
            -1020,  // NSURLErrorDataNotAllowed
        ]
        
        return nsError.domain == NSURLErrorDomain && permissionErrorCodes.contains(nsError.code)
    }
    
    /// 获取用户友好的错误提示
    static func getPermissionErrorMessage() -> String {
        return "请在「设置 > 无线局域网」或「设置 > 蜂窝网络」中允许 Flow 访问网络"
    }
}
