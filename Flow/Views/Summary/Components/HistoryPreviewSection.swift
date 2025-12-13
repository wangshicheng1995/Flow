//
//  HistoryPreviewSection.swift
//  Flow
//
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - 历史记录项数据模型
struct HistoryItem: Identifiable {
    let id = UUID()
    let date: String
    let score: Int
    
    var level: StressLevel {
        StressLevel.from(score: score)
    }
}

// MARK: - 历史记录预览区域
struct HistoryPreviewSection: View {
    let items: [HistoryItem]
    var onViewAll: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题行
            HStack {
                Text("过去的记录")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // 查看全部按钮
                Button(action: { onViewAll?() }) {
                    HStack(spacing: 4) {
                        Text("查看全部")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            // 横向滚动卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        HistoryChip(item: item)
                    }
                    
                    // 更多按钮
                    MoreHistoryChip(action: { onViewAll?() })
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - 历史记录小卡片
struct HistoryChip: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(spacing: 8) {
            // 日期
            Text(item.date)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 分数
            Text("\(item.score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            // 分字
            Text("分")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            // 状态指示器
            Circle()
                .fill(item.level.color)
                .frame(width: 8, height: 8)
        }
        .frame(width: 70, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(item.level.color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - 更多历史按钮
struct MoreHistoryChip: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text("更多")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 70, height: 100)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.tertiarySystemBackground))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HistoryPreviewSection(
            items: [
                .init(date: "12/01", score: 58),
                .init(date: "12/02", score: 64),
                .init(date: "12/03", score: 60),
                .init(date: "12/04", score: 72),
                .init(date: "12/05", score: 45),
                .init(date: "12/06", score: 55)
            ],
            onViewAll: { print("查看全部") }
        )
    }
    .padding(16)
    .background(Color(.systemGroupedBackground))
}
