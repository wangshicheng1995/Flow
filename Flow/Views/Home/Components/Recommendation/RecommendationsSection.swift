//
//  RecommendationsSection.swift
//  Flow
//
//  Created on 2025-12-13.
//

import SwiftUI

struct RecommendationsSection: View {
    private let items: [RecommendationItem] = [
        .init(icon: "bed.double.fill", title: "休息", color: .green),
        .init(icon: "figure.walk", title: "主动恢复", color: .green)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日建议")
                .font(.title3)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                ForEach(items) { item in
                    RecommendationChip(icon: item.icon, title: item.title, color: item.color)
                }
            }
        }
    }
}

private struct RecommendationItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

struct RecommendationChip: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(24)
    }
}

#Preview {
    RecommendationsSection()
        .padding()
}
