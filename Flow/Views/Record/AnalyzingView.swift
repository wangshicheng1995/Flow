//
//  AnalyzingView.swift
//  Flow
//
//  AI 分析等待页面
//  纯 UI 展示，显示拍摄的食物照片和加载状态
//  网络请求由 RecordView 管理
//

import SwiftUI

/// AI 分析等待视图
/// 纯 UI 展示页面，在用户拍照后显示，等待分析完成
/// 网络请求逻辑由 RecordView 管理
struct AnalyzingView: View {
    /// 用户拍摄的食物图片
    let capturedImage: UIImage
    
    /// 关闭回调（用户主动取消）
    var onDismiss: (() -> Void)?
    
    // ⭐️ 圆形图片尺寸（可调整）
    private let circleImageSize: CGFloat = 320
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 主内容
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 中间内容区域
                    VStack(spacing: 24) {
                        // 圆形食物图片
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: circleImageSize, height: circleImageSize)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                        
                        // 分析状态文字
                        VStack(spacing: 8) {
                            Text("正在计算中")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Text("Powered by AI")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer() // 给底部图片留出空间
                }
                
                // ⭐️ 底部 Logo 图片（固定在底部，贴近屏幕边缘）
                VStack {
                    Spacer()
                    Image("stretchingcat")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)  // 👈 调整这个值改变图片大小
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                // 左侧关闭按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyzingView(
        capturedImage: UIImage(systemName: "photo.fill") ?? UIImage()
    )
}
