//
//  GlycemicLoadDetailView.swift
//  Flow
//
//  Created on 2025-12-05.
//

import SwiftUI
import Charts

// MARK: - Glycemic Load Detail View
struct GlycemicLoadDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Mock data for the heart rate chart
    private let heartRateData: [HeartRatePoint] = [
        .init(time: 0, value: 62),
        .init(time: 1, value: 64),
        .init(time: 2, value: 63),
        .init(time: 3, value: 65),
        .init(time: 4, value: 64),
        .init(time: 5, value: 66),
        .init(time: 6, value: 65),
        .init(time: 7, value: 67),
        .init(time: 8, value: 65),
        .init(time: 9, value: 64),
        .init(time: 10, value: 65)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                
                // MARK: - Smiley Face Visual
                smileyFaceView
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                
                // MARK: - Title Section
                titleSection
                    .padding(.horizontal, 24)
                
                // Divider between title and body metrics
                Divider()
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                // MARK: - Body Metrics Section
                bodyMetricsSection
                    .padding(.horizontal, 24)
                
                // MARK: - Metric Cards
                VStack(spacing: 0) {
                    // Resting Heart Rate Card
                    restingHeartRateCard
                    
                    Divider()
                        .padding(.leading, 24)
                    
                    // Wrist Temperature Card
                    wristTemperatureCard
                }
                .padding(.top, 16)
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    // MARK: - Smiley Face View
    private var smileyFaceView: some View {
        ZStack {
            // Left Eye
            SmileyEye()
                .stroke(Color.primary, lineWidth: 3)
                .frame(width: 70, height: 50)
                .offset(x: -60, y: 0)
            
            // Right Eye
            SmileyEye()
                .stroke(Color.primary, lineWidth: 3)
                .frame(width: 70, height: 50)
                .offset(x: 60, y: 0)
            
            // Smile
            SmileyMouth()
                .stroke(Color.primary, lineWidth: 3)
                .frame(width: 100, height: 60)
                .offset(y: 70)
        }
        .frame(height: 180)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("优质蛋白最能支持恢复与饱腹感")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("蛋白质的来源和分布会受到每顿饭搭配、零食选择等多种因素影响，单独看一顿的蛋白含量往往不够全面。要获得更准确的优质蛋白评估，我们建议你持续记录每天的主要正餐和高蛋白食物，Flow 会在多日数据的基础上给出更有参考意义的摘要。")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Body Metrics Section
    private var bodyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("身体指标")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
            
            Text("以下指标为白天测量。白天测量会受到外界噪音的影响，提供的数据不一定准确。")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
    }
    
    // MARK: - Resting Heart Rate Card
    private var restingHeartRateCard: some View {
        Button(action: {}) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                        
                        Text("静息心率")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("65")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("bpm")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        
                        Text("旧数据")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Heart Rate Chart
                Chart {
                    ForEach(heartRateData) { point in
                        LineMark(
                            x: .value("Time", point.time),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(Color.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    ForEach(heartRateData) { point in
                        AreaMark(
                            x: .value("Time", point.time),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.secondary.opacity(0.1), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: 55...75)
                .frame(width: 120, height: 50)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Wrist Temperature Card
    private var wristTemperatureCard: some View {
        Button(action: {}) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                        
                        Text("手腕温度")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("无数据")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        
                        Text("过去 14 天内没有读数")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Smiley Face Shapes

struct SmileyEye: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a curved eye shape (eyebrow-like curve)
        let startPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        let controlPoint = CGPoint(x: rect.midX, y: rect.minY)
        
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        
        return path
    }
}

struct SmileyMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a smile curve
        let startPoint = CGPoint(x: rect.minX, y: rect.minY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let controlPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        
        return path
    }
}

// MARK: - Heart Rate Data Model

struct HeartRatePoint: Identifiable {
    let id = UUID()
    let time: Int
    let value: Int
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GlycemicLoadDetailView()
    }
}
