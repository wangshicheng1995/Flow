//
//  StressStatusBar.swift
//  Flow
//
//  Created on 2025-11-30.
//

import SwiftUI

struct StressStatusBar: View {
    let score: Double
    private let barHeight: CGFloat = 24
    private let spacing: CGFloat = 4
    private let grayWidth: CGFloat = 50
    private let redWidth: CGFloat = 100
    // 指示器尺寸可按需调整
    private let indicatorSize = CGSize(width: 28, height: 38)
    
    // MARK: - 可调整参数
    /// Bar 与文本标签之间的间距，调整此值可改变间距大小
    private let labelTopSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let greenWidth = max(totalWidth - grayWidth - redWidth - spacing * 2, 0)
            let indicatorX = indicatorPosition(
                for: score,
                grayWidth: grayWidth,
                greenWidth: greenWidth,
                redWidth: redWidth,
                spacing: spacing
            )

            VStack(alignment: .leading, spacing: labelTopSpacing) {
                // MARK: - Status Bar
                ZStack(alignment: .leading) {
                    HStack(spacing: spacing) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: grayWidth, height: barHeight)

                        Capsule()
                            .fill(Color.green.opacity(0.6))
                            .frame(width: greenWidth, height: barHeight)

                        Capsule()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: redWidth, height: barHeight)
                    }

                    Image("score")
                        .resizable()
                        .scaledToFit()
                        .frame(width: indicatorSize.width, height: indicatorSize.height)
                        .position(
                            x: clampIndicatorX(indicatorX, totalWidth: totalWidth),
                            y: barHeight / 2
                        )
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                .frame(height: max(barHeight, indicatorSize.height))
                
                // MARK: - Labels
//                HStack(spacing: spacing) {
//                    Text("良好")
//                        .font(.caption2)
//                        .fontWeight(.medium)
//                        .foregroundStyle(.secondary)
//                        .frame(width: grayWidth, alignment: .leading)
//                    
//                    Text("完美")
//                        .font(.caption2)
//                        .fontWeight(.medium)
//                        .foregroundStyle(.green)
//                        .frame(width: greenWidth, alignment: .leading)
//                    
//                    Text("偏重")
//                        .font(.caption2)
//                        .fontWeight(.medium)
//                        .foregroundStyle(.red)
//                        .frame(width: redWidth, alignment: .leading)
//                }
            }
        }
        .frame(height: max(barHeight, indicatorSize.height) + labelTopSpacing + 16) // 16 为文本高度
    }

    private func indicatorPosition(for score: Double,
                                   grayWidth: CGFloat,
                                   greenWidth: CGFloat,
                                   redWidth: CGFloat,
                                   spacing: CGFloat) -> CGFloat {
        let clamped = min(max(score, 0), 100)
        let halfIndicator = indicatorSize.width / 2
        
        if clamped <= 40 {
            // 良好区域：指示器从 halfIndicator 到 grayWidth - halfIndicator
            let ratio = clamped / 40
            let startX = halfIndicator
            let endX = grayWidth - halfIndicator
            return startX + ratio * (endX - startX)
        } else if clamped <= 80 {
            // 完美区域：指示器从 grayWidth + spacing + halfIndicator 到 grayWidth + spacing + greenWidth - halfIndicator
            let ratio = (clamped - 40) / 40
            let startX = grayWidth + spacing + halfIndicator
            let endX = grayWidth + spacing + greenWidth - halfIndicator
            return startX + ratio * (endX - startX)
        } else {
            // 偏重区域：指示器从 grayWidth + spacing + greenWidth + spacing + halfIndicator 到末尾
            let ratio = (clamped - 80) / 20
            let startX = grayWidth + spacing + greenWidth + spacing + halfIndicator
            let endX = grayWidth + spacing + greenWidth + spacing + redWidth - halfIndicator
            return startX + ratio * (endX - startX)
        }
    }

    private func clampIndicatorX(_ x: CGFloat, totalWidth: CGFloat) -> CGFloat {
        let halfWidth = indicatorSize.width / 2
        let minX: CGFloat = halfWidth
        let maxX = totalWidth - halfWidth
        return min(max(x, minX), maxX)
    }
}

#Preview("良好区域") {
    StressStatusBar(score: 20)
        .frame(width: 350)
        .padding()
}

#Preview("完美区域") {
    StressStatusBar(score: 60)
        .frame(width: 350)
        .padding()
}

#Preview("偏重区域") {
    StressStatusBar(score: 90)
        .frame(width: 350)
        .padding()
}
