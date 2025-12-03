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
        }
        .frame(height: max(barHeight, indicatorSize.height))
    }

    private func indicatorPosition(for score: Double,
                                   grayWidth: CGFloat,
                                   greenWidth: CGFloat,
                                   redWidth: CGFloat,
                                   spacing: CGFloat) -> CGFloat {
        let clamped = min(max(score, 0), 100)
        if clamped < 40 {
            let ratio = clamped / 40
            return ratio * grayWidth
        } else if clamped <= 80 {
            let ratio = (clamped - 40) / 40
            return grayWidth + spacing + ratio * greenWidth
        } else {
            let ratio = (clamped - 80) / 20
            return grayWidth + spacing + greenWidth + spacing + ratio * redWidth
        }
    }

    private func clampIndicatorX(_ x: CGFloat, totalWidth: CGFloat) -> CGFloat {
        let halfWidth = indicatorSize.width / 2
        let minX: CGFloat = halfWidth
        let maxX = totalWidth - halfWidth
        return min(max(x, minX), maxX)
    }
}

#Preview {
    StressStatusBar(score: 40)
        .frame(width: 300, height: 40)
        .padding()
}
