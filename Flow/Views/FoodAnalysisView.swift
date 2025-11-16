//
//  FoodAnalysisView.swift
//  Flow
//
//  Created on 2025-11-05.
//

import SwiftUI

struct FoodAnalysisView: View {
    @Environment(\.dismiss) var dismiss
    let analysisData: FoodAnalysisData
    let capturedImage: UIImage

    var body: some View {
        NavigationView {
            ZStack {
                // 背景颜色
                Color(red: 0.11, green: 0.11, blue: 0.15)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 拍摄的食物图片
                        ImagePreviewSection(image: capturedImage)

                        // 分析结果区域
                        AnalysisResultSection(analysisData: analysisData)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("食物分析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // TODO: 保存到数据库
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                }
            }
            .toolbarBackground(Color(red: 0.11, green: 0.11, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Image Preview Section
struct ImagePreviewSection: View {
    let image: UIImage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("拍摄图片")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// MARK: - Analysis Result Section
struct AnalysisResultSection: View {
    let analysisData: FoodAnalysisData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分析结果")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            // 分析文本卡片
            VStack(alignment: .leading, spacing: 12) {
                Text(analysisData.processedText)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )

            // 任务 ID（开发调试用）
            if !analysisData.taskId.isEmpty {
                HStack {
                    Text("任务 ID:")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    Text(analysisData.taskId)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FoodAnalysisView(
        analysisData: FoodAnalysisData(
            taskId: "5c1ef988-f3e0-49cc-8db7-dfa41ce5b982",
            originalPrompt: "请描述这张图片",
            processedText: "这张图片展示了一堆单片独特的餐食。图片中有各种颜色的美味食物，包括绿色蔬菜、橙色和黄色的水果等。",
            summary: nil,
            metadata: nil,
            processedAt: nil
        ),
        capturedImage: UIImage(systemName: "photo")!
    )
}
