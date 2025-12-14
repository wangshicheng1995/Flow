//
//  CalorieIntakeCard.swift
//  Flow
//
//  Created on 2025-12-14.
//

import SwiftUI

/// 首页总热量卡片视图
/// 复刻类 Gentler Streak 的设计风格
struct CalorieIntakeCard: View {
    /// 热量数值（格式化后的字符串，例："1,234"）
    let value: String
    /// 点击卡片时的回调
    var onTap: (() -> Void)?
    
    /// 参考最大值，用于计算水位高度（假设每日推荐摄入 2500）
    private let maxReference: Double = 2500
    
    private var percentage: Double {
        // 移除逗号等非数字字符
        let cleanValue = value.replacingOccurrences(of: ",", with: "")
        let doubleValue = Double(cleanValue) ?? 0
        // 限制在 0.1 到 1.0 之间，保证只要有数值就显示一点水位
        let ratio = doubleValue / maxReference
        return max(0.05, min(ratio, 1.0))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部 Header
            HStack(alignment: .top) {
                Text("总热量")
                    .font(.system(size: 16, weight: .bold)) // 缩小标题
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold)) // 缩小箭头
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding([.top, .horizontal], 16) // 减小边距
            
            // 中间圆形水位图区域
            GeometryReader { geometry in
                let size = geometry.size.height
                let diameter = min(geometry.size.width, size)
                
                ZStack {
                    // 1. 光晕背景
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.98, blue: 0.90), // #FFFAE6
                                    Color(red: 1.0, green: 0.98, blue: 0.92).opacity(0.5),
                                    Color.white.opacity(0.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: diameter / 2
                            )
                        )
                        .blur(radius: 10)
                        .frame(width: diameter * 1.1, height: diameter * 1.1)
                    
                    // 2. 水位层
                    ZStack(alignment: .bottom) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.9),
                                        Color(red: 1.0, green: 0.72, blue: 0.25)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: diameter, height: diameter)
                            .mask(
                                VStack {
                                    Spacer(minLength: 0)
                                    Rectangle()
                                        .frame(height: max(diameter * percentage, 10))
                                        .blur(radius: 2) 
                                }
                            )
                    }
                    
                    // 3. 内容层
                    VStack(spacing: 0) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20)) // 缩小图标
                            .foregroundStyle(Color.black.opacity(0.7))
                            .padding(.bottom, 2)
                        
                        Text(value)
                            .font(.system(size: 32, weight: .black, design: .rounded)) // 缩小数值字体
                            .foregroundStyle(Color.black.opacity(0.9))
                    }
                    .offset(y: -2)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 8)
            
        }
        .frame(height: 150) // 高度调整为 160
        .background(Color(.systemBackground))
        .cornerRadius(24)
        // 阴影效果
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGray6)
            .ignoresSafeArea()
            
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            CalorieIntakeCard(value: "647")
            CalorieIntakeCard(value: "2,000")
        }
        .padding()
    }
}
