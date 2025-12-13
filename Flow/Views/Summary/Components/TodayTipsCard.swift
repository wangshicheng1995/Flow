//
//  TodayTipsCard.swift
//  Flow
//
//  Created on 2025-12-10.
//

import SwiftUI

// MARK: - 今日重点提醒卡片
struct TodayTipsCard: View {
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题行
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.purple)
                
                Text("今日重点提醒")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // AI 标签
                Text("AI")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
            
            // 提示列表
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    TipRow(index: index + 1, text: tip)
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

// MARK: - 单条提示行
struct TipRow: View {
    let index: Int
    let text: String
    
    private let iconColors: [Color] = [.blue, .purple, .orange, .green, .pink]
    
    private var iconColor: Color {
        iconColors[(index - 1) % iconColors.count]
    }
    
    private var icon: String {
        switch index {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        case 3: return "3.circle.fill"
        case 4: return "4.circle.fill"
        case 5: return "5.circle.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        TodayTipsCard(tips: [
            "晚餐的油盐偏多，明天可以尝试少油少盐烹饪。",
            "蛋白质略低，适合在加餐中补一点酸奶或坚果。",
            "今天的总体热量已经接近目标，建议避免睡前进食。"
        ])
        
        TodayTipsCard(tips: [
            "今天的饮食非常均衡，继续保持！"
        ])
    }
    .padding(16)
    .background(Color(.systemGroupedBackground))
}
