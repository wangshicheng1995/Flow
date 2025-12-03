//
//  StressStatusSheet.swift
//  Flow
//
//  Created on 2025-12-12.
//

import SwiftUI

struct StressStatusSheet: View {
    @Environment(\.dismiss) private var dismiss
    let score: Int
    @State private var selectedCardIndex = 0
    @State private var showScoreExplanation = false

    private let cardHeight: CGFloat = 330
    private let cards = MockStressCard.sample
    private var clampedScore: Int { min(max(score, 0), 100) }

    private var statusText: String {
        if clampedScore >= 80 { return "有压力" }
        if clampedScore >= 40 { return "完美" }
        return "轻松"
    }

    private var statusColor: Color {
        if clampedScore >= 80 { return Color.red.opacity(0.8) }
        if clampedScore >= 40 { return Color.green.opacity(0.6) }
        return Color.green.opacity(0.6)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                    .accessibilityLabel("关闭")
                    .buttonStyle(.plain)
                }
                .padding(.top, 40)
                .padding(.trailing, 6)

                VStack(spacing: 12) {
                    Image("catwithfish")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 120)

                    VStack(spacing: 8) {
                        Text(statusText)
                            .font(.system(size: 44, weight: .heavy, design: .rounded))

                        Text("今日食物压力分 \(clampedScore) 分")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("🍚 血糖压力：低    🥓 油脂负担：低    🧂 咸度：低")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.center)

                StressStatusSegmentBar(score: clampedScore)

                TabView(selection: $selectedCardIndex) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        StressSuggestionCard(card: card, highlightColor: statusColor, height: cardHeight)
                            .padding(.horizontal, 6)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: cardHeight + 24)

                HStack(spacing: 8) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedCardIndex ? Color.primary : Color.secondary.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 4)

                Button {
                    withAnimation(.spring()) {
                        showScoreExplanation = true
                    }
                } label: {
                    Text("Flow 是如何计算食物压力分的？")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color(red: 0xF1/255, green: 0xF0/255, blue: 0xF5/255))

            if showScoreExplanation {
                VStack {
                    Spacer()
                    ScoreExplanationView(onClose: {
                        withAnimation(.spring()) {
                            showScoreExplanation = false
                        }
                    })
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut, value: showScoreExplanation)
    }
}

private struct StressStatusSegmentBar: View {
    let score: Int
    private let barHeight: CGFloat = 24
    private let maxBarWidth: CGFloat = 240
    private let indicatorSize = CGSize(width: 28, height: 38)
    private let indicatorTopPadding: CGFloat = 8

    private func clamp(_ score: Int) -> Double {
        Double(min(max(score, 0), 100))
    }

    private func segmentColor(for score: Double) -> Color {
        if score >= 80 { return Color.red.opacity(0.8) }
        if score >= 40 { return Color.green.opacity(0.6) }
        return Color.gray.opacity(0.2)
    }

    private func clampIndicatorX(_ x: CGFloat, totalWidth: CGFloat) -> CGFloat {
        let half = indicatorSize.width / 2
        return min(max(x, half), totalWidth - half)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = min(maxBarWidth, geometry.size.width)
            let normalizedScore = clamp(score) / 100
            let indicatorX = clampIndicatorX(CGFloat(normalizedScore) * totalWidth, totalWidth: totalWidth)
            let color = segmentColor(for: clamp(score))

            HStack {
                Spacer()
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: totalWidth, height: barHeight)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)

                    Capsule()
                        .fill(color)
                        .frame(width: totalWidth, height: barHeight)

                    Image("score")
                        .resizable()
                        .scaledToFit()
                        .frame(width: indicatorSize.width, height: indicatorSize.height)
                        .position(
                            x: indicatorX,
                            y: barHeight / 2
                        )
                        .padding(.top, indicatorTopPadding)
                        .padding(.leading, 5)
                }
                .frame(width: totalWidth, height: max(barHeight, indicatorSize.height + indicatorTopPadding), alignment: .leading)
                Spacer()
            }
        }
        .frame(height: max(barHeight, indicatorSize.height + indicatorTopPadding))
    }
}

private struct MockStressCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let action: String
    let icon: String

    static let sample: [MockStressCard] = [
        .init(title: "休息", subtitle: "今天已经吃得较重口，适当放松和补水，让身体更轻松。", action: "今天选择休息", icon: "bed.double.fill"),
        .init(title: "轻度活动", subtitle: "散步 20 分钟促进消化，搭配蔬菜水果保持纤维摄入。", action: "去走一走", icon: "figure.walk"),
        .init(title: "补水提醒", subtitle: "每小时补水 200ml，帮助代谢掉多余盐分和糖分。", action: "现在喝水", icon: "drop.fill")
    ]
}

private struct StressSuggestionCard: View {
    let card: MockStressCard
    let highlightColor: Color
    var height: CGFloat = 230

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 10) {
                Image(systemName: card.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(highlightColor)
                    .frame(width: 72, height: 72)
                    .background(
                        Circle()
                            .fill(highlightColor.opacity(0.12))
                    )

                Text(card.title)
                    .font(.headline)
                    .foregroundStyle(highlightColor)
            }
            .frame(maxWidth: .infinity)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text(card.subtitle)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: {}) {
                    Text("详情")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)

            Button(action: {}) {
                Text(card.action)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(highlightColor.opacity(0.9))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

struct ScoreExplanationView: View {
    var onClose: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("食物压力分是怎么来的？")
                    .font(.headline)
                Spacer()
                Button("知道了") {
                    onClose?()
                }
                .font(.subheadline.weight(.semibold))
            }

            Text("我们会根据你今天的饮食，从几个维度来估算身体的负担：")
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 6) {
                Label("油脂：油炸、肥肉越多，分数越高", systemImage: "drop.fill")
                Label("糖分：甜饮料、甜品会增加压力", systemImage: "cube.fill")
                Label("咸度：偏咸、重口味会推高分数", systemImage: "takeoutbag.and.cup.and.straw.fill")
                Label("蔬菜与纤维：蔬菜少，分数也会升高", systemImage: "leaf.fill")
            }
            .font(.footnote)

            Text("分数越低，代表今天的饮食对身体越友好；分数越高，表示身体需要更多时间来“消化”这些负担。")
                .font(.footnote)
                .padding(.top, 4)
        }
        .padding()
    }
}
#Preview {
    StressStatusSheet(score: 40)
}

#Preview {
    StressStatusSheet(score: 85)
}
