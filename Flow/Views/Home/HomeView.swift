//
//  HomeView.swift
//  Flow
//
//  Created on 2025-11-25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    @ObservedObject var bannerManager = BannerManager.shared
    @EnvironmentObject var stressScoreViewModel: StressScoreViewModel
    @State private var isShowingStressSheet = false
    @State private var isShowingGlycemicLoad = false
    @State private var isShowingCalorieIntake = false
    @State private var isShowingHighQualityProtein = false
    
    // MARK: - Banner 布局调节参数
    /// Banner 显示区域的高度 - 调小此值可以让 banner 更矮，类似 Gentler Streak 的效果
    private let bannerHeight: CGFloat = 280
    /// 图片垂直偏移 - 正值向下移动（显示图片上半部分），负值向上移动（显示图片下半部分）
    private let bannerImageOffset: CGFloat = 60
    /// 内容区域与 banner 的间距 - 正值增加空白，负值让内容上移覆盖部分 banner
    private let contentTopSpacing: CGFloat = 12

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                // MARK: - Banner Section
                ZStack(alignment: .bottom) {
                    Image(bannerManager.dailyBannerName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(y: bannerImageOffset)
                        .frame(height: bannerHeight)
                        .clipped()
                    
                    // Gradient Mask - 渐变过渡效果
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: bannerHeight * 0.35) // 渐变区域占 banner 高度的 35%
                }
                .contentShape(Rectangle()) // 确保整个区域可点击
                .onTapGesture {
                    if BannerManager.enableTapToChangeBanner {
                        bannerManager.randomizeBanner()
                    }
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: bannerManager.dailyBannerName)
                .ignoresSafeArea(.all, edges: .top)
                
                // MARK: - Content Section
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("嗨, \(authManager.userGivenName)")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Text("Flow 吃的健康")
                            .font(.title)
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
                            Text("今日饮食")
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
                            
                            // 总热量卡片 - 点击进入 CalorieIntakeView
                            WellnessCard(title: "总热量", icon: "figure.walk", value: "3,240", unit: "步", isPromo: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isShowingCalorieIntake = true
                                }
                            
                            // 优质蛋白卡片 - 点击进入 HighQualityProteinView
                            WellnessCard(title: "优质蛋白", icon: "heart.fill", value: "72", unit: "bpm", isPromo: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isShowingHighQualityProtein = true
                                }

                            // 糖负荷卡片 - 点击进入 GlycemicLoadView
                            WellnessCard(title: "糖负荷", icon: "bed.double.fill", value: "7h 30m", unit: "睡眠时间", isPromo: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isShowingGlycemicLoad = true
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, contentTopSpacing)
                .background(Color(.systemBackground)) // Ensure background adapts to theme
            } // Content VStack
            } // ScrollView
            .background(Color(.systemBackground))
            .ignoresSafeArea(.container, edges: .top)
            .sheet(isPresented: $isShowingStressSheet) {
                StressStatusSheet(score: stressScoreViewModel.currentScore)
                    .presentationDetents([.fraction(1)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(28)
            }
            .navigationDestination(isPresented: $isShowingGlycemicLoad) {
                GlycemicLoadView()
            }
            .navigationDestination(isPresented: $isShowingCalorieIntake) {
                CalorieIntakeView()
            }
            .navigationDestination(isPresented: $isShowingHighQualityProtein) {
                HighQualityProteinView()
            }
            .task {
                await stressScoreViewModel.refreshScore()
            }
        } // NavigationStack
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
