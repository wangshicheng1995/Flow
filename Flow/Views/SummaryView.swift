//
//  SummaryView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - 摘要视图
struct SummaryView: View {
    var body: some View {
        ZStack {
            // 背景颜色
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 顶部标题
                    HStack {
                        Text("Summary")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // 健康概览卡片
                    HealthOverviewCard()
                        .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SummaryView()
}
