//
//  SplashView.swift
//  Flow
//
//  开屏首页 - 展示 Flow Logo
//  采用极简设计风格，参考 Oportun 设计
//  Created on 2025-12-29.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 纯白背景
            OnboardingDesign.backgroundColor
                .ignoresSafeArea()
            
            // Logo 区域
            VStack(spacing: 0) {
                Spacer()
                
                // Flow Logo
                flowLogo
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                
                Spacer()
            }
        }
        .onAppear {
            // 启动动画
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Flow Logo
    private var flowLogo: some View {
        Text("Flow")
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .foregroundColor(OnboardingDesign.primaryTextColor)
    }
}

#Preview {
    SplashView()
}
