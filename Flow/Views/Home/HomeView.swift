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
    @EnvironmentObject var homeDataViewModel: HomeDataViewModel
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
        mainContent
    }
    
    // MARK: - 主内容视图
    private var mainContent: some View {
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("嗨, \(authManager.userGivenName)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("你的身体是你吃出来的")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        if let quote = QuoteManager.shared.dailyQuote {
                            Text(quote.text)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .lineSpacing(4)
                        }
                    }
                    
                    // 间隔区域（调整 height 值来控制 quote 和 Status Bar 之间的距离）
                    Spacer()
                        .frame(height: 18)
                    
                    // Status Bar - 使用 HomeDataViewModel 的数据
                    StressStatusBar(score: Double(homeDataViewModel.stressScore))
                        .frame(height: 26)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isShowingStressSheet = true
                        }
                        .sensoryFeedback(.selection, trigger: isShowingStressSheet)
                    
                    // Recommendations
                   RecommendationsSection()
                }
                .padding(.horizontal, 24)
                .padding(.top, contentTopSpacing)
                .background(Color(.systemBackground)) // Ensure background adapts to theme
                
                // MARK: - 今日饮食 Dashboard Section
                // 独立的全宽背景区块，背景色 #EBEAF1
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("今日饮食")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        
                        // 加载指示器
                        if homeDataViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        
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
                        // MARK: - 推广卡片
                        HealthJourneyPromoCard()
                        
                        // MARK: - 总热量卡片
                        CalorieIntakeCard(
                            value: homeDataViewModel.formattedCalories,
                            onTap: { isShowingCalorieIntake = true }
                        )
                        
                        // MARK: - 优质蛋白卡片
                        HighQualityProteinCard(
                            value: homeDataViewModel.formattedProteinCount,
                            onTap: { isShowingHighQualityProtein = true }
                        )

                        // MARK: - 糖负荷卡片
                        GlycemicLoadCard(
                            value: homeDataViewModel.formattedGlycemicLoad,
                            onTap: { isShowingGlycemicLoad = true }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGray6))
                .padding(.top, 22) // 调整此值可增减与上方「今日建议」的间距（在灰色背景外部）
            } // Content VStack
            } // ScrollView
            .refreshable {
                // 下拉刷新
                await homeDataViewModel.loadAllData()
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(.container, edges: .top)
            .sheet(isPresented: $isShowingStressSheet) {
                StressStatusSheet(score: homeDataViewModel.stressScore)
                    .presentationDetents([.fraction(1)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(28)
            }
            .navigationDestination(isPresented: $isShowingGlycemicLoad) {
                GlycemicLoadDetailView()
            }
            .navigationDestination(isPresented: $isShowingCalorieIntake) {
                CalorieIntakeDetailView()
            }
            .navigationDestination(isPresented: $isShowingHighQualityProtein) {
                HighQualityProteinDetailView()
            }
            .task {
                // 首次加载所有数据
                if !homeDataViewModel.hasLoadedOnce {
                    await homeDataViewModel.loadAllData()
                }
            }
        } // NavigationStack
    } // mainContent
}

#Preview {
    HomeView()
        .environmentObject(HomeDataViewModel())
}

