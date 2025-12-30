//
//  ActivityLevelView.swift
//  Flow
//
//  Onboarding 页面: 日常活动水平选择
//  精确复刻设计稿的拨盘交互
//  Created on 2025-12-28.
//

import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // 拨盘旋转角度状态
    @State private var dialRotation: Double = 0
    @State private var dragOffset: Double = 0
    
    // 配置常量
    private let levels = ActivityLevel.allCases
    private let anglePerItem: Double = 36 // 每个选项之间的角度间隔（增大避免重叠）
    private let dialRadius: CGFloat = 320 // 拨盘半径
    
    // 设计稿颜色
    private let accentColor = Color(red: 1.0, green: 0.545, blue: 0.376) // #FF8B60
    private let tickGray = Color(red: 0.80, green: 0.80, blue: 0.80)
    private let labelGray = Color(red: 0.75, green: 0.75, blue: 0.75)
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. 顶部图标区域
            iconCard
                .padding(.top, 24)
                .padding(.bottom, 24)
            
            // 2. 描述文字 (补充说明)
            descriptionText
                .padding(.bottom, 20)
            
            // 3. 底部拨盘区域 (上移以填补空白)
            dialSection
                .padding(.top, 50)
            
            Spacer() // 垫片放底部，把内容往上推
        }
        .frame(maxWidth: .infinity) // 依靠父容器限制宽度，替代 UIScreen.main
        .clipped() // 裁剪超出部分
        .onAppear {
            initializeDialPosition()
        }
        .onChange(of: viewModel.userProfile.activityLevel) { oldValue, newValue in
            syncDialToSelection(newValue)
        }
    }
    
    // MARK: - 描述文字区域
    private var descriptionText: some View {
        Text(viewModel.userProfile.activityLevel.description)
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .id("desc_\(viewModel.userProfile.activityLevel.rawValue)")
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.25), value: viewModel.userProfile.activityLevel)
    }
    
    // MARK: - 顶部图标卡片
    private var iconCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                .frame(width: 100, height: 100)
            
            Image(systemName: viewModel.userProfile.activityLevel.icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                .id("icon_\(viewModel.userProfile.activityLevel.rawValue)")
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
        }
    }
    

    
    // MARK: - 底部拨盘区域
    private var dialSection: some View {
        ZStack {
            dialWheel
                .offset(y: dialRadius * 0.65) // 整体下移，露出更多的顶部圆弧
        }
        .frame(height: 260) // 增加高度以容纳上方文字
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
        .contentShape(Rectangle())
    }
    
    // MARK: - 拨盘轮
    private var dialWheel: some View {
        ZStack {
            // 1. 弧形轨道背景
            arcBackground
            
            // 2. 刻度线（随拖动旋转）
            tickMarks
                .rotationEffect(.degrees(dialRotation + dragOffset))
            
            // 3. 文字标签（随拖动旋转）
            textLabels
                .rotationEffect(.degrees(dialRotation + dragOffset))
            
            // 4. 中心指示线（固定）+ 光晕
            centerIndicator
        }
        .gesture(dragGesture)
    }
    
    // MARK: - 弧形轨道背景
    private var arcBackground: some View {
        ZStack {
            // 两个圆叠加产生"切口"效果，或者简单用一个线条
            // 设计稿中似乎是一条连续的细线，中间被高亮区域覆盖
            
            Circle()
                .trim(from: 0.58, to: 0.92)
                .stroke(
                    LinearGradient(
                        colors: [
                            tickGray.opacity(0.1),
                            tickGray.opacity(0.5),
                            tickGray.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round) // 极细的线
                )
                .frame(width: dialRadius * 2, height: dialRadius * 2)
                .offset(y: 10) // 微调位置，对应刻度底部
                .rotationEffect(.degrees(180))
        }
    }
    
    // MARK: - 刻度线
    private var tickMarks: some View {
        ZStack {
            ForEach(0..<levels.count, id: \.self) { index in
                let itemAngle = Double(index - levels.count / 2) * anglePerItem
                let isCenter = isSelectedIndex(index)
                
                // 刻度线 (放在文字下方)
                Capsule()
                    .fill(isCenter ? accentColor : tickGray)
                    .frame(width: isCenter ? 4 : 2, height: isCenter ? 24 : 12) // 刻度线变短
                    .offset(y: -dialRadius + 90) // 往下移 (Y越大越靠下)
                    .rotationEffect(.degrees(itemAngle))
                    .animation(.easeInOut(duration: 0.15), value: dialRotation)
            }
        }
    }
    
    // MARK: - 文字标签（倾斜排列，位于刻度上方）
    private var textLabels: some View {
        ZStack {
            ForEach(0..<levels.count, id: \.self) { index in
                let itemAngle = Double(index - levels.count / 2) * anglePerItem
                let isCenter = isSelectedIndex(index)
                let distanceFromCenter = abs(Double(index) - currentVisualIndex)
                
                Text(levels[index].displayName)
                    .font(.system(size: isCenter ? 24 : 16, weight: isCenter ? .heavy : .medium)) // 选中字体更大
                    .foregroundColor(isCenter ? .black : labelGray.opacity(max(0.3, 1 - distanceFromCenter * 0.4)))
                    .offset(y: -dialRadius + 40) // 往上移，位于刻度上方 (Y越小越靠上)
                    .rotationEffect(.degrees(itemAngle))
                    .scaleEffect(isCenter ? 1.1 : 1.0) // 选中时轻微放大
                    .animation(.easeInOut(duration: 0.15), value: dialRotation)
            }
        }
    }
    
    // MARK: - 中心指示线 + 光晕
    private var centerIndicator: some View {
        ZStack {
            // 光晕（放在刻度线位置）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.2), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .offset(y: -dialRadius + 90) //跟随刻度位置
            
            // 中心指示线 (主题色)
            Capsule()
                .fill(accentColor)
                .frame(width: 4, height: 28)
                .offset(y: -dialRadius + 90)
                .shadow(color: accentColor.opacity(0.5), radius: 4, x: 0, y: 0)
        }
    }
    
    // MARK: - 拖动手势
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let sensitivity: Double = 0.35
                dragOffset = Double(value.translation.width) * sensitivity
            }
            .onEnded { value in
                dialRotation += dragOffset
                dragOffset = 0
                snapToNearestItem()
            }
    }
    
    // MARK: - 辅助计算
    
    private var currentVisualIndex: Double {
        let centerIndex = Double(levels.count / 2)
        return centerIndex - (dialRotation + dragOffset) / anglePerItem
    }
    
    private func isSelectedIndex(_ index: Int) -> Bool {
        return abs(Double(index) - currentVisualIndex) < 0.5
    }
    
    private func initializeDialPosition() {
        if let index = levels.firstIndex(of: viewModel.userProfile.activityLevel) {
            let centerIndex = levels.count / 2
            dialRotation = Double(centerIndex - index) * anglePerItem
        }
    }
    
    private func syncDialToSelection(_ level: ActivityLevel) {
        if let index = levels.firstIndex(of: level) {
            let centerIndex = levels.count / 2
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                dialRotation = Double(centerIndex - index) * anglePerItem
            }
        }
    }
    
    private func snapToNearestItem() {
        let centerIndex = Double(levels.count / 2)
        let rawIndex = centerIndex - dialRotation / anglePerItem
        var snappedIndex = Int(round(rawIndex))
        snappedIndex = max(0, min(levels.count - 1, snappedIndex))
        
        viewModel.userProfile.activityLevel = levels[snappedIndex]
        
        let targetRotation = Double(Int(centerIndex) - snappedIndex) * anglePerItem
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            dialRotation = targetRotation
        }
    }
}

#Preview {
    OnboardingPageContainer {
        ActivityLevelView(viewModel: OnboardingViewModel())
    }
}
