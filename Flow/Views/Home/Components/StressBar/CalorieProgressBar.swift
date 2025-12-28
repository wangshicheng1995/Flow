//
//  CalorieProgressBar.swift
//  Flow
//
//  Modern, minimalistic calorie progress bar component
//  Design: Clean, rounded, healing aesthetic with gradient fill
//
//  Created on 2025-12-28.
//

import SwiftUI

// MARK: - Calorie Progress Bar

/// A modern, continuous gradient progress bar for displaying remaining calories
/// Features glassmorphism knob, smooth animations, and healing color palette
struct CalorieProgressBar: View {
    // MARK: - Properties
    
    /// Calories consumed today
    let consumedCalories: Double
    /// Total daily calorie target
    let totalCalories: Double
    
    // MARK: - Configuration
    
    private let barHeight: CGFloat = 14
    private let knobSize: CGFloat = 22
    
    // MARK: - Colors
    
    /// Soft warm orange (gradient start)
    private let gradientStart = Color(red: 255/255, green: 166/255, blue: 108/255)
    /// Coral pink / lavender (gradient end)
    private let gradientEnd = Color(red: 186/255, green: 130/255, blue: 255/255)
    /// Track background
    private let trackColor = Color.gray.opacity(0.1)
    
    // MARK: - Computed Properties
    
    /// Remaining calories to eat
    private var remainingCalories: Int {
        max(0, Int(totalCalories - consumedCalories))
    }
    
    /// Progress ratio (0.0 - 1.0)
    private var progress: Double {
        guard totalCalories > 0 else { return 0 }
        return min(max(consumedCalories / totalCalories, 0), 1)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Calorie Text
            calorieTextSection
            
            // Bottom Row: Progress Bar
            progressBarSection
        }
    }
    
    // MARK: - Calorie Text Section
    
    private var calorieTextSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Large calorie number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(remainingCalories)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 21/255, green: 21/255, blue: 21/255))
                
                Text("kcal")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 120/255, green: 120/255, blue: 120/255))
            }
            
            // Subtitle
            Text("还可以吃")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Progress Bar Section
    
    private var progressBarSection: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let fillWidth = totalWidth * progress
            
            ZStack(alignment: .leading) {
                // Track (Background)
                Capsule()
                    .fill(trackColor)
                    .frame(height: barHeight)
                
                // Fill (Foreground) with Gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [gradientStart, gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(fillWidth, barHeight), height: barHeight)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                
                // Glassmorphism Knob
                knobIndicator
                    .offset(x: max(fillWidth - knobSize / 2, 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
            }
        }
        .frame(height: knobSize)
    }
    
    // MARK: - Knob Indicator
    
    private var knobIndicator: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: knobSize + 4, height: knobSize + 4)
                .blur(radius: 4)
            
            // Main knob with glassmorphism effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.white.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: knobSize, height: knobSize)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview("剩余热量 - 574 kcal") {
    VStack(spacing: 40) {
        CalorieProgressBar(
            consumedCalories: 1426,
            totalCalories: 2000
        )
        .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}

#Preview("低消耗") {
    VStack(spacing: 40) {
        CalorieProgressBar(
            consumedCalories: 300,
            totalCalories: 2000
        )
        .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}

#Preview("接近目标") {
    VStack(spacing: 40) {
        CalorieProgressBar(
            consumedCalories: 1850,
            totalCalories: 2000
        )
        .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}

#Preview("超出目标") {
    VStack(spacing: 40) {
        CalorieProgressBar(
            consumedCalories: 2200,
            totalCalories: 2000
        )
        .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}
