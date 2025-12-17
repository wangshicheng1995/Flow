//
//  AnalyzingView.swift
//  Flow
//
//  AI 分析等待页面
//  显示拍摄的食物照片，等待 API 返回分析结果
//

import SwiftUI

/// AI 分析等待视图
/// 在用户拍照后显示，等待 FlowService 返回分析结果
struct AnalyzingView: View {
    /// 用户拍摄的食物图片
    let capturedImage: UIImage
    
    /// 关闭回调（返回拍照页面）
    var onDismiss: (() -> Void)?
    
    /// 分析完成回调，传递分析结果
    var onAnalysisComplete: ((FoodAnalysisData) -> Void)?
    
    /// 分析失败回调
    var onAnalysisError: ((String) -> Void)?
    
    // MARK: - State
    @State private var isAnalyzing = true
    @State private var errorMessage: String?
    @State private var showError = false
    
    // ⭐️ 圆形图片尺寸（可调整）
    private let circleImageSize: CGFloat = 320
    
    var body: some View {
        ZStack {
            // 背景色
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    // 左侧关闭按钮
                    Button(action: {
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
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
                        Text("Estimating portions")
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
                Image("google")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)  // 👈 调整这个值改变图片大小
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .task {
            await startAnalysis()
        }
        .alert("分析失败", isPresented: $showError) {
            Button("重试") {
                Task {
                    await startAnalysis()
                }
            }
            Button("返回", role: .cancel) {
                onDismiss?()
            }
        } message: {
            Text(errorMessage ?? "未知错误")
        }
    }
    
    // MARK: - 开始分析
    @MainActor
    private func startAnalysis() async {
        isAnalyzing = true
        errorMessage = nil
        
        do {
            print("📤 AnalyzingView: 开始上传图片...")
            let result = try await FoodAnalysisService.shared.uploadImage(capturedImage)
            print("✅ AnalyzingView: 分析完成，返回 \(result.foods.count) 种食物")
            
            isAnalyzing = false
            onAnalysisComplete?(result)
            
        } catch let error as APIError {
            print("❌ AnalyzingView: API 错误 - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isAnalyzing = false
            showError = true
            
        } catch {
            print("❌ AnalyzingView: 未知错误 - \(error.localizedDescription)")
            errorMessage = "图片分析失败，请重试"
            isAnalyzing = false
            showError = true
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyzingView(
        capturedImage: UIImage(systemName: "photo.fill") ?? UIImage()
    )
}
