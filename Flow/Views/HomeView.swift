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

    var body: some View {
        ZStack {
            // 背景颜色
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部标题栏
                HeaderView()
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()

                // 中间相机区域
                CameraPlaceholderView()
                    .padding(.horizontal, 32)

                Spacer()

                // 底部按钮栏
                BottomButtonsView(viewModel: viewModel)
                    .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            CameraView(onImageCaptured: { image in
                viewModel.handleCapturedImage(image)
            })
        }
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryView()
        }
        .alert("需要相机权限", isPresented: $viewModel.showPermissionAlert) {
            Button("前往设置") {
                viewModel.openSettings()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("Flow 需要使用相机来识别您的食物。请在设置中允许访问相机。")
        }
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16) {
                // 标题
                Text("今日健康")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                // 健康货币进度
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("健康货币")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))

                        Spacer()

                        Text("剩余 1250")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                    }

                    // 进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 背景
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 12)

                            // 进度
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.8, blue: 0.2),
                                            Color(red: 1.0, green: 0.6, blue: 0.1)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.625, height: 12)
                        }
                    }
                    .frame(height: 12)
                }
            }

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
        HStack(spacing: 32) {
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

            // 拍照按钮（中间大按钮）
            Button(action: {
                Task {
                    await viewModel.handleCameraButtonTap()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.2),
                                    Color(red: 1.0, green: 0.5, blue: 0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 88, height: 88)

                    Image(systemName: "fork.knife")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            // 历史记录按钮
            Button(action: {
                viewModel.showHistoryView()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 72, height: 72)

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - History View (占位)
struct HistoryView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.11, blue: 0.15)
                    .ignoresSafeArea()

                VStack {
                    Text("历史记录")
                        .font(.title)
                        .foregroundColor(.white)

                    // TODO: 实现历史记录列表
                }
            }
            .navigationTitle("历史回顾")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
