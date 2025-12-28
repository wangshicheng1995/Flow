//
//  BodyMeasurementView.swift
//  Flow
//
//  Onboarding 页面 3: 身高体重输入
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct BodyMeasurementView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // BMI 显示卡片
            bmiCard
            
            // 身高输入
            heightSection
            
            // 体重输入
            weightSection
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - BMI 卡片
    private var bmiCard: some View {
        VStack(spacing: 8) {
            Text("BMI")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", viewModel.userProfile.bmi))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(viewModel.userProfile.bmiDescription)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(bmiColor)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }
    
    // MARK: - 身高区域
    private var heightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("身高", systemImage: "arrow.up.and.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(Int(viewModel.userProfile.heightCm)) cm")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
            }
            
            Slider(
                value: $viewModel.userProfile.heightCm,
                in: 100...220,
                step: 1
            )
            .tint(Color.accentColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 体重区域
    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("体重", systemImage: "scalemass.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f kg", viewModel.userProfile.weightKg))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
            }
            
            Slider(
                value: $viewModel.userProfile.weightKg,
                in: 30...200,
                step: 0.5
            )
            .tint(Color.accentColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - BMI 颜色
    private var bmiColor: Color {
        switch viewModel.userProfile.bmi {
        case ..<18.5: return .blue
        case 18.5..<24: return .green
        case 24..<28: return .orange
        default: return .red
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        BodyMeasurementView(viewModel: OnboardingViewModel())
    }
}
