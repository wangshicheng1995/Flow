//
//  BirthYearSelectionView.swift
//  Flow
//
//  Onboarding 页面 2: 出生年份选择
//  采用 iOS 26 Liquid Glass 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct BirthYearSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // 年份范围
    private let currentYear = Calendar.current.component(.year, from: Date())
    private var yearRange: [Int] {
        Array((currentYear - 100)...(currentYear - 10)).reversed()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 年龄显示
            ageDisplay
            
            // 年份选择器
            yearPicker
            
            // 说明文字
            infoText
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 年龄显示
    private var ageDisplay: some View {
        VStack(spacing: 8) {
            Text("\(viewModel.userProfile.age)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("岁")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
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
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }
    
    // MARK: - 年份选择器
    private var yearPicker: some View {
        VStack(spacing: 12) {
            Text("选择出生年份")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            Picker("出生年份", selection: $viewModel.userProfile.birthYear) {
                ForEach(yearRange, id: \.self) { year in
                    Text("\(year) 年")
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - 说明文字
    private var infoText: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text("年龄会影响每日热量需求的计算")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "f8f9fa").ignoresSafeArea()
        BirthYearSelectionView(viewModel: OnboardingViewModel())
    }
}
