import SwiftUI
import Charts

struct FoodAnalysisView: View {
    @Environment(\.dismiss) var dismiss
    
    // Properties to maintain compatibility
    let analysisData: FoodAnalysisData
    let capturedImage: UIImage
    
    // Mock Data for the chart
    let progressData: [ProgressPoint] = [
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
                    // Header
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
                            Text("汉堡")
                                .font(.system(size: 17, weight: .semibold))
                            HStack(spacing: 4) {
                                Text("2025 年 12 月 4 日")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.orange)
//                                Image(systemName: "chevron.right")
//                                    .font(.system(size: 10, weight: .bold))
//                                    .foregroundStyle(.orange)
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
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Main Visual (Aura)
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
//                            Image(systemName: "shoe.2.fill") // Closest SF Symbol to footprints
//                                .font(.system(size: 40))
//                                .foregroundStyle(Color(red: 0.8, green: 0.4, blue: 0.0))
//                                .rotationEffect(.degrees(-15))
                            
                            Text("营养均衡")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.8, green: 0.4, blue: 0.0))
                            
                            HStack(spacing: 4) {
//                                Image(systemName: "arrow.up.circle.fill")
//                                    .font(.system(size: 14))
                                Text("比最近一周的午餐要健康一些")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundStyle(Color(red: 0.8, green: 0.4, blue: 0.0).opacity(0.8))
                        }
                    }
                    .frame(height: 400)
                    
                    // Stats Grid
                    VStack(spacing: 24) {
                        HStack(spacing: 0) {
                            StatItem(title: "总热量", value: "1.2", unit: "mi")
                            Spacer()
                            StatItem(title: "碳水", value: "0", unit: "h", value2: "21", unit2: "m")
                        }
                        
                        HStack(spacing: 0) {
                            StatItem(title: "蛋白质", value: "2", unit: "floors")
                            Spacer()
                            StatItem(title: "关键风险指标（钠）", value: "90", unit: "bpm")
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日压力")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("vs. typical Wednesday • 1012 steps")
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
                    .padding(24)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Helper Views & Models

struct StatItem: View {
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

struct ProgressPoint: Identifiable {
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
    FoodAnalysisView(
        analysisData: FoodAnalysisData(
            foods: [],
            nutrition: Nutrition(energyKcal: 0, proteinG: 0, fatG: 0, carbG: 0, fiberG: 0, sodiumMg: 0, sugarG: 0, satFatG: 0),
            confidence: 0,
            isBalanced: false,
            nutritionSummary: "",
            overallEvaluation: nil,
            impact: nil
        ),
        capturedImage: UIImage()
    )
}
