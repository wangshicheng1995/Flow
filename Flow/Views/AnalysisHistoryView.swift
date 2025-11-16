//
//  AnalysisHistoryView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI
import SwiftData

// MARK: - 食物分析历史列表页
struct AnalysisHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodRecord.timestamp, order: .reverse) private var records: [FoodRecord]

    @State private var selectedRecord: FoodRecord?
    @State private var showDetail = false

    var body: some View {
        ZStack {
            // 背景颜色
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()

            if records.isEmpty {
                // 空状态
                EmptyAnalysisState()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(records) { record in
                            AnalysisHistoryCard(record: record)
                                .onTapGesture {
                                    selectedRecord = record
                                    showDetail = true
                                }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            if let record = selectedRecord {
                // TODO: 创建历史记录详情视图
                NavigationView {
                    ZStack {
                        Color(red: 0.11, green: 0.11, blue: 0.15)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text(record.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("热量：")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(record.calories) kcal")
                                        .foregroundColor(.white)
                                }
                                HStack {
                                    Text("健康评分：")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(record.healthScore)")
                                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                                }
                                if let notes = record.notes {
                                    Text(notes)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.top, 8)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        .padding(24)
                    }
                    .navigationTitle("详情")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完成") {
                                showDetail = false
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
    }
}

// MARK: - 分析历史卡片
struct AnalysisHistoryCard: View {
    let record: FoodRecord

    var body: some View {
        HStack(spacing: 16) {
            // 食物图片占位（暂时使用占位图，后续可从 imagePath 加载）
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                }

            // 分析信息
            VStack(alignment: .leading, spacing: 8) {
                // 食物名称
                Text(record.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // 营养信息预览
                HStack(spacing: 12) {
                    Text("\(record.calories) kcal")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))

                    Text("•")
                        .foregroundColor(.white.opacity(0.5))

                    Text("健康评分 \(record.healthScore)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.8))
                }

                // 时间
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    Text(formattedDate(record.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - 空状态视图
struct EmptyAnalysisState: View {
    var body: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.4))
            }

            // 提示文字
            VStack(spacing: 8) {
                Text("暂无分析记录")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text("开始拍摄您的食物\n获取健康分析建议")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AnalysisHistoryView()
        .modelContainer(for: [FoodRecord.self], inMemory: true)
}

#Preview("With Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FoodRecord.self, configurations: config)

    // 添加示例数据
    let record1 = FoodRecord(
        name: "水果沙拉",
        calories: 250,
        healthScore: 92,
        timestamp: Date().addingTimeInterval(-3600),
        notes: "富含维生素C和膳食纤维，有助于提升免疫力和促进消化。"
    )

    let record2 = FoodRecord(
        name: "鸡胸肉配蔬菜",
        calories: 420,
        healthScore: 88,
        timestamp: Date().addingTimeInterval(-7200),
        notes: "优质蛋白质来源，搭配新鲜蔬菜，营养均衡，适合健身人群食用。"
    )

    container.mainContext.insert(record1)
    container.mainContext.insert(record2)

    return AnalysisHistoryView()
        .modelContainer(container)
}
