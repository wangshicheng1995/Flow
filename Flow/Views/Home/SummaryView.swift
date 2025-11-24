//
//  SummaryView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - Data Models

enum TimeRange: String, CaseIterable {
    case week = "周"
    case month = "月"
    case year = "年"
    case allTime = "全部"
}

struct SummaryMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let color: Color
}

struct HistoryItem: Identifiable {
    let id = UUID()
    let date: String
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let lineValue: Double // 0.0 to 1.0 normalized
    let barValue: Double // 0.0 to 1.0 normalized
}

// MARK: - Mock Data

struct MockData {
    static let metrics: [SummaryMetric] = [
        SummaryMetric(title: "平均摄入", value: "2150", unit: "kcal", color: .orange),
        SummaryMetric(title: "运动消耗", value: "450", unit: "kcal", color: .green),
        SummaryMetric(title: "平均睡眠", value: "7.5", unit: "小时", color: .blue),
        SummaryMetric(title: "水分摄入", value: "2.1", unit: "升", color: .cyan)
    ]
    
    static let history: [HistoryItem] = [
        HistoryItem(date: "今天, 10:30", title: "早餐 - 燕麦牛奶", value: "350", unit: "kcal", icon: "cup.and.saucer.fill", color: .orange),
        HistoryItem(date: "昨天, 19:00", title: "晚餐 - 鸡胸肉沙拉", value: "420", unit: "kcal", icon: "fork.knife", color: .green),
        HistoryItem(date: "昨天, 12:30", title: "午餐 - 牛肉盖饭", value: "780", unit: "kcal", icon: "takeoutbag.and.cup.and.straw.fill", color: .red),
        HistoryItem(date: "11月17日, 08:00", title: "晨跑", value: "300", unit: "kcal", icon: "figure.run", color: .blue),
        HistoryItem(date: "11月16日, 23:00", title: "睡眠", value: "8.0", unit: "小时", icon: "bed.double.fill", color: .purple)
    ]
    
    static let chartData: [ChartDataPoint] = [
        ChartDataPoint(month: "Jan", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Feb", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Mar", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Apr", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "May", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Jun", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Jul", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Aug", lineValue: 0.4, barValue: 0.0),
        ChartDataPoint(month: "Sep", lineValue: 0.4, barValue: 0.05),
        ChartDataPoint(month: "Oct", lineValue: 0.42, barValue: 0.6),
        ChartDataPoint(month: "Nov", lineValue: 0.8, barValue: 0.5),
        ChartDataPoint(month: "Dec", lineValue: 0.8, barValue: 0.0)
    ]
}

// MARK: - SummaryView

struct SummaryView: View {
    // MARK: - State
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetricId: UUID? = MockData.metrics.first?.id
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Time Range Switcher
                    timeRangeSwitcher
                    
                    // Chart Section
                    ChartSection()
                    
                    // Summary Cards Grid
                    summaryCardsGrid
                    
                    // History Section
                    historySection
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("总览")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Optional: Add a profile image or settings button here if needed
            Image(systemName: "person.crop.circle")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 24)
    }
    
    private var timeRangeSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTimeRange = range
                    }
                }) {
                    Text(range.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selectedTimeRange == range ? .black : .white) // Selected text black, unselected white
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedTimeRange == range {
                                    RoundedRectangle(cornerRadius: 20) // More rounded
                                        .fill(Color.white) // White background for selection
                                        .matchedGeometryEffect(id: "RangeBackground", in: namespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color(red: 0.2, green: 0.2, blue: 0.25)) // Darker background for container
        .cornerRadius(24) // Fully rounded container
        .padding(.horizontal, 24)
    }
    
    @Namespace private var namespace
    
    private var summaryCardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(MockData.metrics) { metric in
                SummaryCard(metric: metric, isSelected: selectedMetricId == metric.id)
                    .onTapGesture {
                        withAnimation {
                            selectedMetricId = metric.id
                        }
                    }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("历史记录")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(MockData.history) { item in
                    HistoryRow(item: item)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Chart Section

struct ChartSection: View {
    var body: some View {
        VStack(spacing: 20) {
            // Chart Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("2025")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    Text("vs. 2024")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("SHARE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            
            // Chart Area
            ZStack {
                // Grid Lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                            .background(Color.white.opacity(0.1))
                        Spacer()
                    }
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
                
                // Y-Axis Labels (Right Side)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("02:20").padding(.bottom, 25)
                        Text("01:45").padding(.bottom, 25)
                        Text("01:10").padding(.bottom, 25)
                        Text("00:35").padding(.bottom, 25)
                        Text("00:15")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.6))
                }
                
                // Chart Content
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let height = proxy.size.height
                    let data = MockData.chartData
                    let stepX = width / CGFloat(data.count - 1)
                    
                    // Bar Chart
                    ForEach(0..<data.count, id: \.self) { i in
                        let point = data[i]
                        if point.barValue > 0 {
                            let barHeight = height * point.barValue
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 12, height: barHeight)
                                .position(x: CGFloat(i) * stepX, y: height - barHeight / 2)
                        }
                    }
                    
                    // Line Chart
                    Path { path in
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height * (1 - point.lineValue)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                // Smooth curve
                                let prevX = CGFloat(index - 1) * stepX
                                let prevY = height * (1 - data[index - 1].lineValue)
                                let control1 = CGPoint(x: prevX + stepX / 2, y: prevY)
                                let control2 = CGPoint(x: x - stepX / 2, y: y)
                                path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                            }
                        }
                    }
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    // Cursor Line & Dot (Hardcoded for demo at Nov)
                    let cursorIndex = 10 // Nov
                    let cursorX = CGFloat(cursorIndex) * stepX
                    let cursorY = height * (1 - data[cursorIndex].lineValue)
                    
                    // Vertical Line
                    Path { path in
                        path.move(to: CGPoint(x: cursorX, y: 0))
                        path.addLine(to: CGPoint(x: cursorX, y: height))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    
                    // Dot on Line
                    Circle()
                        .stroke(Color.orange, lineWidth: 3)
                        .background(Circle().fill(Color.white)) // White fill
                        .frame(width: 12, height: 12)
                        .position(x: cursorX, y: cursorY)
                    
                    // Dot on X-Axis
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .position(x: cursorX, y: height * 0.6) // Approx intersection with horizontal line
                }
                .padding(.trailing, 40) // Space for Y-axis labels
            }
            .frame(height: 200)
            .padding(.horizontal, 24)
            
            // X-Axis Labels
            HStack(spacing: 0) {
                ForEach(MockData.chartData) { point in
                    Text(point.month)
                        .font(.system(size: 10))
                        .foregroundColor(point.month == "Nov" ? .white : .gray) // Highlight Nov
                        .fontWeight(point.month == "Nov" ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.trailing, 40) // Align with chart
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }
}

// MARK: - Components

struct SummaryCard: View {
    let metric: SummaryMetric
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(metric.title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(metric.value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(metric.unit)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.15, blue: 0.2))
        .cornerRadius(16)
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(isSelected ? metric.color : Color.clear)
                    .frame(height: 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? metric.color.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct HistoryRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundColor(item.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(item.date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(item.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(item.unit)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.15, blue: 0.2))
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    SummaryView()
}
