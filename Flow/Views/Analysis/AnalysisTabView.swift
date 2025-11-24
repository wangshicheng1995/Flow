//
//  AnalysisTabView.swift
//  Flow
//
//  Created on 2025-11-17.
//

import SwiftUI

// MARK: - Analysis Tab 容器视图
struct AnalysisTabView: View {
    @State private var analysisStateManager = AnalysisStateManager.shared

    var body: some View {
        ZStack {
            // 背景颜色
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()

            if let analysisData = analysisStateManager.latestAnalysisData,
               let capturedImage = analysisStateManager.latestCapturedImage {
                // 显示最新的分析结果
                FoodAnalysisView(analysisData: analysisData, capturedImage: capturedImage)
                    .onAppear {
                        // 标记为已查看
                        analysisStateManager.markAsViewed()
                    }
            } else {
                // 显示空状态，提示用户先拍照
                EmptyAnalysisTabState()
            }
        }
    }
}

// MARK: - 空状态视图
struct EmptyAnalysisTabState: View {
    var body: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.4))
            }

            // 提示文字
            VStack(spacing: 8) {
                Text("暂无分析结果")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text("请先在 Photo 页面拍摄食物\n获取营养分析")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AnalysisTabView()
}
