//
//  CalorieIntakeDetailView.swift
//  Flow
//
//  Created on 2025-12-05.
//

import SwiftUI
import Charts

struct CalorieIntakeDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    // Mock Data for the chart
    private let progressData: [CalorieProgressPoint] = [
        .init(hour: 6, steps: 0, type: .current),
        .init(hour: 8, steps: 500, type: .current),
        .init(hour: 10, steps: 1200, type: .current),
        .init(hour: 12, steps: 1800, type: .current),
        .init(hour: 14, steps: 2453, type: .current),
        
        .init(hour: 6, steps: 0, type: .typical),
        .init(hour: 8, steps: 400, type: .typical),
        .init(hour: 10, steps: 800, type: .typical),
        .init(hour: 12, steps: 1500, type: .typical),
        .init(hour: 14, steps: 2000, type: .typical),
        .init(hour: 16, steps: 3500, type: .typical),
        .init(hour: 18, steps: 5000, type: .typical),
        .init(hour: 20, steps: 6500, type: .typical),
        .init(hour: 22, steps: 7000, type: .typical)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    auraView
                        .frame(height: 400)
                    
                    statsGridView
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    progressSectionView
                        .padding(24)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("今日摄入")
                    .font(.system(size: 17, weight: .semibold))
                HStack(spacing: 4) {
                    Text("2025 年 12 月 14 日")
                        .font(.system(size: 14))
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
    
    private var auraView: some View {
        ZStack {
            // Aura Gradient
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.4))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(y: -20)
                
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(y: 20)
            }
            .padding(.top, 20)
            
            // Content
            VStack(spacing: 16) {
                Text("营养均衡")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.8, green: 0.4, blue: 0.0))
                
                HStack(spacing: 4) {
                    Text("比最近一周的平均摄入要健康一些")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(Color(red: 0.8, green: 0.4, blue: 0.0).opacity(0.8))
            }
        }
    }
    
    private var statsGridView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 0) {
                CalorieStatItem(title: "总热量", value: "2000", unit: "kcal")
                Spacer()
                CalorieStatItem(title: "碳水", value: "250", unit: "g")
            }
            
            HStack(spacing: 0) {
                CalorieStatItem(title: "蛋白质", value: "95", unit: "g")
                Spacer()
                CalorieStatItem(title: "脂肪", value: "70", unit: "g")
            }
        }
    }
    
    private var progressSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日趋势")
                    .font(.system(size: 20, weight: .bold))
                
                Text("vs. 典型的一天")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            
            Chart {
                ForEach(progressData) { item in
                    LineMark(
                        x: .value("Hour", item.hour),
                        y: .value("Steps", item.steps)
                    )
                    .foregroundStyle(item.type == .current ? Color.orange : Color.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXScale(domain: 6...22)
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(values: [6, 12, 18]) { value in
                    AxisValueLabel(format: .dateTime.hour())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 200)
        }
    }
}

// MARK: - Helper Views & Models

private struct CalorieStatItem: View {
    let title: String
    let value: String
    let unit: String
    var value2: String? = nil
    var unit2: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                
                Text(unit)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                
                if let v2 = value2, let u2 = unit2 {
                    Text(v2)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.leading, 4)
                    
                    Text(u2)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CalorieProgressPoint: Identifiable {
    let id = UUID()
    let hour: Int
    let steps: Int
    let type: DataType
    
    enum DataType {
        case current
        case typical
    }
}

#Preview {
    CalorieIntakeDetailView()
}
