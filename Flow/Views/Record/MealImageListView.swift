//
//  MealImageListView.swift
//  Flow
//
//  临时验收页面：显示所有已存储的餐食图片
//  用于验证本地图片存储功能是否正常工作
//

import SwiftUI

/// 餐食图片列表视图（临时验收用）
struct MealImageListView: View {
    @State private var storedImages: [StoredMealImage] = []
    @State private var totalStorageSize: Double = 0
    @State private var isLoading = true
    
    // 图片网格列配置
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if storedImages.isEmpty {
                    emptyStateView
                } else {
                    imageGridView
                }
            }
            .navigationTitle("已存储图片")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: refreshImages) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                if !storedImages.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .destructive, action: deleteAllImages) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadImages()
        }
        // 监听图片上传通知，自动刷新
        .onReceive(NotificationCenter.default.publisher(for: .didUploadFood)) { _ in
            loadImages()
        }
    }
    
    // MARK: - 子视图
    
    /// 加载中视图
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("加载中...")
                .foregroundColor(.secondary)
        }
    }
    
    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("暂无已存储的图片")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("拍照或从相册选择图片后\n图片会自动保存到本地")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Button(action: refreshImages) {
                Label("刷新", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .padding(.top, 10)
        }
        .padding()
    }
    
    /// 图片网格视图
    private var imageGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 存储信息统计
                storageInfoCard
                
                // 图片网格
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(storedImages) { storedImage in
                        imageCell(for: storedImage)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
    
    /// 存储信息卡片
    private var storageInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("共 \(storedImages.count) 张图片")
                    .font(.headline)
                Text(String(format: "占用空间：%.2f MB", totalStorageSize))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "externaldrive.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    /// 单个图片单元格
    private func imageCell(for storedImage: StoredMealImage) -> some View {
        VStack(spacing: 4) {
            // 图片
            Group {
                if let image = storedImage.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(height: 100)
            .clipped()
            .cornerRadius(8)
            
            // 时间标签
            Text(formatDate(storedImage.createdAt))
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    // MARK: - 方法
    
    /// 加载图片列表
    private func loadImages() {
        isLoading = true
        
        // 使用异步避免阻塞 UI
        DispatchQueue.global(qos: .userInitiated).async {
            let images = MealImageStorage.shared.getAllStoredImages()
            let size = MealImageStorage.shared.getTotalStorageSize()
            
            DispatchQueue.main.async {
                self.storedImages = images
                self.totalStorageSize = size
                self.isLoading = false
            }
        }
    }
    
    /// 刷新图片列表
    private func refreshImages() {
        loadImages()
    }
    
    /// 删除所有图片
    private func deleteAllImages() {
        do {
            try MealImageStorage.shared.deleteAllImages()
            storedImages = []
            totalStorageSize = 0
            print("🗑️ MealImageListView: 所有图片已删除")
        } catch {
            print("❌ MealImageListView: 删除失败 - \(error)")
        }
    }
    
    /// 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    MealImageListView()
}
