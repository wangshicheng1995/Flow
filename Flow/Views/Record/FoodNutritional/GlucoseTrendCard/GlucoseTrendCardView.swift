//
//  GlucoseTrendCardView.swift
//  Flow
//
//  血糖趋势卡片组件 - 参考设计图进行 1:1 还原
//  设计特点: 渐变折线图、Y轴刻度、时间标签、底部图例
//
//  Created on 2025-12-28.
//

import SwiftUI

// MARK: - 血糖趋势卡片视图

/// 血糖趋势卡片组件
/// 展示餐后血糖变化趋势的渐变折线图
struct GlucoseTrendCardView: View {
    // MARK: - 属性
    
    /// 血糖趋势数据
    let data: GlucoseTrendData
    /// 是否可见（用于滑入动画）
    var isVisible: Bool = true
    /// 点击卡片时的回调
    var onTap: (() -> Void)?
    
    // MARK: - 状态
    
    /// 是否显示 tips
    @State private var showTips = false
    
    /// 硬编码的 tips 内容（后续接入接口）
    private let tipsContent = "本次升糖峰值主要来自精制碳水，脂肪含量较高，使回落过程更缓慢。若餐后轻度活动，曲线可能更平缓。"
    
    // MARK: - 设计稿颜色
    
    private let textPrimary = Color(red: 21/255, green: 21/255, blue: 21/255)
    private let textSecondary = Color(red: 77/255, green: 77/255, blue: 77/255)
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    
    /// 渐变起始颜色（橙色）- 对应 Metric 1
    private let gradientStartColor = Color(red: 255/255, green: 149/255, blue: 0/255)
    /// 渐变结束颜色（蓝色）- 对应 Metric 2
    private let gradientEndColor = Color(red: 66/255, green: 165/255, blue: 245/255)
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题区域
            headerSection
            
            Spacer()
                .frame(height: 16)
            
            // 折线图区域
            GradientChartView(
                data: data,
                startColor: gradientStartColor,
                endColor: gradientEndColor
            )
            .frame(height: 180)
            
            Spacer()
                .frame(height: 16)
            
            // 底部图例
            legendSection
            
            // Tips 显示区域（点击箭头后展开）
            if showTips {
                tipsSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
    
    // MARK: - 标题区域
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            // 左侧标题
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("餐后升糖趋势")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                Text("(模拟)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textTertiary)
            }
            
            Spacer()
            
            // 右侧箭头按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTips.toggle()
                }
            }) {
                Image(systemName: showTips ? "chevron.up" : "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 底部图例
    
    private var legendSection: some View {
        HStack(spacing: 24) {
            Spacer()
            
            // Metric 1 - 橙色（升糖负担偏高）
            HStack(spacing: 8) {
                Circle()
                    .fill(gradientStartColor)
                    .frame(width: 8, height: 8)
                
                Text("升糖负担偏高")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
            }
            
            // Metric 2 - 蓝色（负担回落）
            HStack(spacing: 8) {
                Circle()
                    .fill(gradientEndColor)
                    .frame(width: 8, height: 8)
                
                Text("负担回落")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Tips 区域
    
    private var tipsSection: some View {
        HStack(alignment: .top, spacing: 10) {
            // 左侧图标
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 255/255, green: 193/255, blue: 7/255))
                .padding(.top, 2)
            
            // Tips 内容
            Text(tipsContent)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 255/255, green: 250/255, blue: 240/255))
        )
        .padding(.top, 12)
    }
}

// MARK: - 渐变折线图组件

/// 渐变折线图组件
/// 根据数据绘制从橙色到蓝色的渐变折线
private struct GradientChartView: View {
    let data: GlucoseTrendData
    let startColor: Color
    let endColor: Color
    
    /// Y轴级别标签（从上到下：高影响 → 中影响 → 低影响）
    private let yAxisLabels = ["高影响", "中影响", "低影响"]
    
    /// 文字颜色
    private let textTertiary = Color(red: 153/255, green: 153/255, blue: 153/255)
    /// 网格线颜色
    private let gridLineColor = Color(red: 230/255, green: 230/255, blue: 230/255)
    
    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width - 60 // 右侧留出Y轴标签空间
            let chartHeight = geometry.size.height - 30 // 底部留出X轴标签空间
            let chartOriginX: CGFloat = 0
            let chartOriginY: CGFloat = 0
            
            ZStack(alignment: .topLeading) {
                // Y轴刻度和网格线
                yAxisAndGridLines(
                    chartOriginX: chartOriginX,
                    chartOriginY: chartOriginY,
                    chartWidth: chartWidth,
                    chartHeight: chartHeight
                )
                
                // 折线图（带渐变）
                gradientLine(
                    chartOriginX: chartOriginX,
                    chartOriginY: chartOriginY,
                    chartWidth: chartWidth,
                    chartHeight: chartHeight
                )
                
                // X轴时间标签
                xAxisLabels(
                    chartOriginX: chartOriginX,
                    chartOriginY: chartOriginY,
                    chartWidth: chartWidth,
                    chartHeight: chartHeight
                )
            }
        }
    }
    
    // MARK: - Y轴和网格线
    
    private func yAxisAndGridLines(
        chartOriginX: CGFloat,
        chartOriginY: CGFloat,
        chartWidth: CGFloat,
        chartHeight: CGFloat
    ) -> some View {
        ForEach(Array(yAxisLabels.enumerated()), id: \.offset) { index, label in
            let y = chartOriginY + (CGFloat(index) / CGFloat(yAxisLabels.count - 1)) * chartHeight
            
            ZStack {
                // 网格线
                Path { path in
                    path.move(to: CGPoint(x: chartOriginX, y: y))
                    path.addLine(to: CGPoint(x: chartOriginX + chartWidth, y: y))
                }
                .stroke(gridLineColor, lineWidth: 1)
                
                // Y轴标签（移到右侧）
                Text(label)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(textTertiary)
                    .position(x: chartOriginX + chartWidth + 30, y: y)
            }
        }
    }
    
    // MARK: - 渐变折线
    
    private func gradientLine(
        chartOriginX: CGFloat,
        chartOriginY: CGFloat,
        chartWidth: CGFloat,
        chartHeight: CGFloat
    ) -> some View {
        let points = generateChartPoints(
            chartOriginX: chartOriginX,
            chartOriginY: chartOriginY,
            chartWidth: chartWidth,
            chartHeight: chartHeight
        )
        
        return ZStack {
            // 为每个线段绘制带颜色的路径
            ForEach(0..<max(0, points.count - 1), id: \.self) { index in
                Path { path in
                    path.move(to: points[index])
                    path.addLine(to: points[index + 1])
                }
                .stroke(
                    colorForSegment(index: index, total: points.count - 1),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
    
    // MARK: - X轴标签
    
    private func xAxisLabels(
        chartOriginX: CGFloat,
        chartOriginY: CGFloat,
        chartWidth: CGFloat,
        chartHeight: CGFloat
    ) -> some View {
        let labels = generateTimeLabels()
        
        return HStack(spacing: 0) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.leading, chartOriginX)
        .padding(.trailing, 60) // 右侧留出Y轴标签空间
        .offset(y: chartHeight + 10)
    }
    
    // MARK: - 辅助方法
    
    /// 生成图表数据点
    private func generateChartPoints(
        chartOriginX: CGFloat,
        chartOriginY: CGFloat,
        chartWidth: CGFloat,
        chartHeight: CGFloat
    ) -> [CGPoint] {
        guard data.glucoseValues.count > 1 else { return [] }
        
        let maxTime = Double(data.timePoints.last ?? 120)
        let minValue: Double = 0
        let maxValue: Double = 100
        
        // 将血糖值映射到 0-100 范围
        let normalizedValues = data.glucoseValues.map { value in
            min(100, max(0, ((value - data.normalRangeLow) / (data.normalRangeHigh - data.normalRangeLow)) * 100))
        }
        
        return data.timePoints.enumerated().map { index, time in
            let x = chartOriginX + (CGFloat(time) / CGFloat(maxTime)) * chartWidth
            let normalizedValue = normalizedValues[index]
            let y = chartOriginY + chartHeight - (CGFloat(normalizedValue) / CGFloat(maxValue - minValue)) * chartHeight
            return CGPoint(x: x, y: y)
        }
    }
    
    /// 根据线段索引获取颜色（渐变效果）
    private func colorForSegment(index: Int, total: Int) -> Color {
        guard total > 0 else { return startColor }
        
        let progress = Double(index) / Double(total)
        
        // 从橙色渐变到蓝色
        return Color(
            red: (1 - progress) * 1.0 + progress * 0.26,
            green: (1 - progress) * 0.58 + progress * 0.65,
            blue: (1 - progress) * 0.0 + progress * 0.96
        )
    }
    
    /// 生成时间标签
    private func generateTimeLabels() -> [String] {
        // 使用餐后时间段格式
        return ["餐后 0–30 分钟", "餐后 30–60 分钟", "餐后 1–3 小时"]
    }
}

// MARK: - Preview

#Preview("血糖趋势卡片") {
    VStack(spacing: 16) {
        GlucoseTrendCardView(
            data: GlucoseTrendData(
                timePoints: [0, 15, 30, 45, 60, 90, 120],
                glucoseValues: [95, 125, 148, 138, 118, 102, 94],
                peakValue: 148,
                peakTimeMinutes: 30,
                impactLevel: "MEDIUM",
                recoveryTimeMinutes: 110,
                normalRangeLow: 70,
                normalRangeHigh: 140
            )
        )
    }
    .padding(22)
    .background(Color(red: 249/255, green: 248/255, blue: 246/255))
}
