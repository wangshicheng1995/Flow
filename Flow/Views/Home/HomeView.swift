//
//  HomeView.swift
//  Flow
//
//  Created on 2025-11-25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    @EnvironmentObject var stressScoreViewModel: StressScoreViewModel
    @State private var isShowingStressSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Banner Section
                ZStack(alignment: .bottom) {
                    Image("banner")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400) // Adjust height as needed
                        .clipped()
                    
                    // Gradient Mask
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120) // Occupy bottom 20-30%
                }
                .ignoresSafeArea(.all, edges: .top)
                
                // MARK: - Content Section
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("嗨, \(authManager.userGivenName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Flow 吃的健康")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        if let quote = QuoteManager.shared.dailyQuote {
                            Text("\(quote.text) ——《\(quote.bookTitle)》")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        } else {
                            Text("运动是增肌和发育的绝佳方式。然而，肌肉也需要时间来恢复。在此期间，你的身体会修复训练中可能产生的微小撕裂。")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    
                    // Status Bar
                    StressStatusBar(score: Double(stressScoreViewModel.currentScore))
                        .frame(height: 26)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isShowingStressSheet = true
                        }
                        .sensoryFeedback(.selection, trigger: isShowingStressSheet)
                    
                    // Recommendations
                    RecommendationsSection()
                    
                    // Wellness
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("健康状况")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            WellnessCard(title: "开启你的\n健康之旅", icon: nil, value: nil, unit: nil, isPromo: true)
                            WellnessCard(title: "步数", icon: "figure.walk", value: "3,240", unit: "步", isPromo: false)
                            WellnessCard(title: "睡眠", icon: "bed.double.fill", value: "7h 30m", unit: "睡眠时间", isPromo: false)
                            WellnessCard(title: "心率", icon: "heart.fill", value: "72", unit: "bpm", isPromo: false)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("健康状况")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            WellnessCard(title: "开启你的\n健康之旅", icon: nil, value: nil, unit: nil, isPromo: true)
                            WellnessCard(title: "步数", icon: "figure.walk", value: "3,240", unit: "步", isPromo: false)
                            WellnessCard(title: "睡眠", icon: "bed.double.fill", value: "7h 30m", unit: "睡眠时间", isPromo: false)
                            WellnessCard(title: "心率", icon: "heart.fill", value: "72", unit: "bpm", isPromo: false)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("健康状况")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(.primary)
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            WellnessCard(title: "开启你的\n健康之旅", icon: nil, value: nil, unit: nil, isPromo: true)
                            WellnessCard(title: "步数", icon: "figure.walk", value: "3,240", unit: "步", isPromo: false)
                            WellnessCard(title: "睡眠", icon: "bed.double.fill", value: "7h 30m", unit: "睡眠时间", isPromo: false)
                            WellnessCard(title: "心率", icon: "heart.fill", value: "72", unit: "bpm", isPromo: false)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, -40) // Pull content up slightly if needed, or let gradient handle blend
                .background(Color(.systemBackground)) // Ensure background adapts to theme
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $isShowingStressSheet) {
            StressStatusSheet(score: stressScoreViewModel.currentScore)
                .presentationDetents([.fraction(1)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
        .task {
            await stressScoreViewModel.refreshScore()
        }
    }
}

struct WellnessCard: View {
    let title: String
    let icon: String?
    let value: String?
    let unit: String?
    let isPromo: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if !isPromo {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(unit ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(height: 140)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
        .environmentObject(StressScoreViewModel())
}
