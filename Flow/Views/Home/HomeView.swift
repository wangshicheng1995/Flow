//
//  HomeView.swift
//  Flow
//
//  Created on 2025-11-05.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.selectedTab) private var selectedTab
    @State private var showCenterHint = false
    @State private var hintDismissTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            // ========================
            // 相机预览（全屏背景）
            // ========================
            CameraPreviewView(
                capturedImage: .constant(nil),
                onImageCaptured: { image in
                    viewModel.handleCapturedImage(image)
                }
            )
            .ignoresSafeArea()

            // ========================
            // 顶部标题栏
            // ========================
            VStack {
                HeaderView()
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()
            }

            // ========================
            // 底部按钮栏
            // ========================
            VStack {
                Spacer()

                BottomButtonsView(viewModel: viewModel)
                    .padding(.bottom, 40)
            }

            if showCenterHint {
                Text("请将相机对准您的食物")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }

            // 加载指示器
            if viewModel.isAnalyzing {
                LoadingOverlayView()
            }
        }
        .alert("分析失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
        .onAppear {
            triggerCenterHint()
        }
        .onDisappear {
            hintDismissTask?.cancel()
            hintDismissTask = nil
            showCenterHint = false
        }
        .onChange(of: selectedTab.wrappedValue) { _, newValue in
            if newValue == .photo {
                triggerCenterHint()
            }
        }
        .onChange(of: viewModel.showAnalysisResult) { _, newValue in
            if newValue {
                // 分析完成，自动切换到 Analysis tab
                selectedTab.wrappedValue = .analysis
            }
        }
    }

    @MainActor
    private func triggerCenterHint() {
        hintDismissTask?.cancel()
        showCenterHint = true

        hintDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeOut) {
                showCenterHint = false
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack(alignment: .center) {
            // 标题
            Text("Flow")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // 用户头像按钮
            Button(action: {
                // 跳转到用户资料页面
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Camera Placeholder View
struct CameraPlaceholderView: View {
    var body: some View {
        ZStack {
            // 背景卡片
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            // 提示文字
            Text("将相机对准您的食物")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(height: 400)
    }
}

// MARK: - Bottom Buttons View
struct BottomButtonsView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        HStack {
            // 从相册选择按钮
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 72, height: 72)

                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Loading Overlay View
struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("正在分析食物...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
