//
//  AgeSelectionView.swift
//  Flow
//
//  Onboarding 页面: 年龄选择
//  采用 Oportun 设计风格
//  Created on 2025-12-28.
//

import SwiftUI

struct AgeSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // 年龄范围：10-100岁
    private let ageRange: [Int] = Array(10...100)
    
    var body: some View {
        VStack(spacing: 24) {
            // 年龄选择器
            agePickerSection
            
            Spacer()
        }
        .padding(.horizontal, OnboardingDesign.horizontalPadding)
        .padding(.top, 32)
    }
    
    // MARK: - 年龄选择器
    private var agePickerSection: some View {
        Picker("年龄", selection: $viewModel.userProfile.age) {
            ForEach(ageRange, id: \.self) { age in
                Text("\(age)")
                    .tag(age)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 200)
    }
}

#Preview {
    OnboardingPageContainer {
        VStack {
            OnboardingTitleView(title: "你的年龄是？", subtitle: "用于计算基础代谢率")
                .padding(.horizontal, OnboardingDesign.horizontalPadding)
            AgeSelectionView(viewModel: OnboardingViewModel())
        }
    }
}
