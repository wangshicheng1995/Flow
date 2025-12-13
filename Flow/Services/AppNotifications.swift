//
//  AppNotifications.swift
//  Flow
//
//  Created on 2025-12-13.
//

import Foundation

/// App 全局通知名称定义
/// 用于跨页面/组件的事件通信
extension Notification.Name {
    
    // MARK: - 食物上传相关
    
    /// 食物照片上传成功
    /// 触发时机：用户拍照/选择照片并成功上传分析后
    /// 监听方：HomeView 需要刷新首页数据
    static let didUploadFood = Notification.Name("didUploadFood")
    
    /// 食物记录被删除
    /// 触发时机：用户删除某条食物记录后
    /// 监听方：HomeView、SummaryView 需要刷新数据
    static let didDeleteFoodRecord = Notification.Name("didDeleteFoodRecord")
    
    // MARK: - 用户状态相关
    
    /// 用户登录成功
    static let didUserLogin = Notification.Name("didUserLogin")
    
    /// 用户登出
    static let didUserLogout = Notification.Name("didUserLogout")
    
    // MARK: - 数据刷新相关
    
    /// 请求刷新首页数据
    /// 可由任意页面发出，HomeView 监听并响应
    static let shouldRefreshHomeData = Notification.Name("shouldRefreshHomeData")
}
