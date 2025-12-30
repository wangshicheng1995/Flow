//
//  BodyMeasurementView.swift
//  Flow
//
//  Onboarding 页面: 身高体重输入
//  采用 Oportun 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct BodyMeasurementView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // BMI 显示卡片
            bmiCard
            
            // 身高输入
            heightSection
            
            // 体重输入
            weightSection
            
            Spacer()
        }
        .padding(.horizontal, OnboardingDesign.horizontalPadding)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    // MARK: - BMI 卡片
    private var bmiCard: some View {
        VStack(spacing: 8) {
            Text("BMI")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(OnboardingDesign.secondaryTextColor)
            
            // 使用三明治布局保证数值居中且不重叠
            HStack(alignment: .center, spacing: 12) {
                // 左侧占位（隐藏）- 需要加上 badge 的宽度和间距
                Text("正常") // 占位文字长度相近即可
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .hidden()
                
                // 中间数值
                Text(String(format: "%.1f", viewModel.userProfile.bmi))
                    .font(.system(size: 48, weight: .bold)) // 稍微加大字号
                    .foregroundColor(OnboardingDesign.primaryTextColor)
                
                // 右侧显示描述 - 胶囊样式
                Text(viewModel.userProfile.bmiDescription)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(bmiColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(bmiColor.opacity(0.15)) // 浅色背景
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - 身高区域
    private var heightSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("身高")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(OnboardingDesign.primaryTextColor)
                
                Spacer()
                
                Text("\(Int(viewModel.userProfile.heightCm)) cm")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(OnboardingDesign.accentColor)
            }
            
            // 身高刻度尺
            ScaleRulerWrapper(
                value: $viewModel.userProfile.heightCm,
                range: 100...220,
                step: 1,
                majorStep: 10,
                scaleSize: 10
            )
        }
        .padding(16)
    }
    
    // MARK: - 体重区域
    private var weightSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("体重")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(OnboardingDesign.primaryTextColor)
                
                Spacer()
                
                // 显示为斤，智能去除 .0
                Text(formattedWeight)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(OnboardingDesign.accentColor)
            }
            
            // 体重刻度尺 (单位：斤，精度 0.5)
            ScaleRulerWrapper(
                value: $viewModel.userProfile.weightJin,
                range: 60...300,
                step: 1,      // 1斤一个刻度
                majorStep: 10, // 10斤一个大刻度
                scaleSize: 10 // 每个刻度间隔 10pt
            )
        }
        .padding(16)
    }
    
    // 格式化体重字符串
    private var formattedWeight: String {
        let jin = viewModel.userProfile.weightJin
        // 如果小数部分为0，则显示整数
        if jin.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f 斤", jin)
        } else {
            return String(format: "%.1f 斤", jin)
        }
    }
    
    // MARK: - BMI 颜色
    private var bmiColor: Color {
        switch viewModel.userProfile.bmi {
        case ..<18.5: return .blue
        case 18.5..<24: return OnboardingDesign.accentColor
        case 24..<28: return .orange
        default: return .red
        }
    }
}

#Preview {
    OnboardingPageContainer {
        VStack {
            OnboardingTitleView(title: "身高和体重", subtitle: "用于计算你的 BMI 和每日需求")
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
            BodyMeasurementView(viewModel: OnboardingViewModel())
        }
    }
}
