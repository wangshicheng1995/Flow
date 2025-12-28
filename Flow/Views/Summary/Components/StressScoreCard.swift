//
//  StressScoreCard.swift
//  Flow
//
//  压力分数卡片组件
//

import SwiftUI

// MARK: - Stress Score 卡片
struct StressScoreCard: View {
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // 标题行
                HStack {
                    Text("Stress Score")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(SummaryColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SummaryColors.textSecondary)
                }
                
                // 内容区域
                HStack(alignment: .bottom, spacing: 0) {
                    // 左侧：分数和状态
                    VStack(alignment: .leading, spacing: 8) {
                        Text("46")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(SummaryColors.textPrimary)
                        
                        Text("Manageable")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(SummaryColors.accentGreen)
                    }
                    
                    Spacer()
                    
                    // 右侧：折线图
                    StressLineChart()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(SummaryColors.cardBgColor)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 压力折线图
struct StressLineChart: View {
    var body: some View {
        // 模拟折线图数据点
        let points: [CGFloat] = [0.5, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.5, 0.7, 0.4, 0.6, 0.5, 0.7, 0.6, 0.5]
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = width / CGFloat(points.count - 1)
            
            Path { path in
                for (index, point) in points.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - (point * height * 0.8) - height * 0.1
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                SummaryColors.accentBlue,
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 150, height: 50)
    }
}

#Preview {
    StressScoreCard()
        .padding()
        .background(SummaryColors.bgColor)
}
