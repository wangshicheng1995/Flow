//
//  FoodAnalysisView.swift
//  Flow
//
//  Created on 2025-11-05.
//

import SwiftUI

struct FoodAnalysisView: View {
    @Environment(\.dismiss) var dismiss
    let analysisData: FoodAnalysisData
    let capturedImage: UIImage
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Body Impact Section
                        BodyImpactView()
                        
                        // Forecast Section
                        if let impact = analysisData.impact {
                            ForecastView(impactAnalysis: impact)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.8), .transparent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text(analysisData.isBalanced ? "BALANCED CHOICE" : "MODERATE CHOICE")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(4)
                    
                    Text("\(analysisData.nutrition.energyKcal) kcal")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Text(analysisData.foods.map { $0.name }.joined(separator: " & "))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(analysisData.nutritionSummary)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding()
        }
    }
}

// MARK: - Body Impact View
struct BodyImpactView: View {
    @State private var selectedTime: String = "Now"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Body Impact")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(["Now", "Later"], id: \.self) { time in
                        Text(time)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTime == time ? Color.white.opacity(0.3) : Color.clear)
                            .foregroundColor(selectedTime == time ? .white : .gray)
                            .cornerRadius(12)
                            .onTapGesture {
                                withAnimation {
                                    selectedTime = time
                                }
                            }
                    }
                }
                .padding(2)
                .background(Color.white.opacity(0.1))
                .cornerRadius(14)
            }
            
            // Mock Body Visualization
            ZStack {
                // Silhouette (Simplified)
                Image(systemName: "figure.stand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .foregroundColor(.white.opacity(0.1))
                
                // Glowing Dots (Mock Data)
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .shadow(color: .green, radius: 5)
                    .offset(x: 0, y: -60) // Head
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 12, height: 12)
                    .shadow(color: .orange, radius: 5)
                    .offset(x: -10, y: -30) // Chest
                
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 12, height: 12)
                    .shadow(color: .yellow, radius: 5)
                    .offset(x: 5, y: -20) // Stomach
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            
            HStack {
                Image(systemName: "info.circle")
                Text("Tap highlighted zones to see details")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Forecast View
struct ForecastView: View {
    let impactAnalysis: ImpactAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Forecast")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 20) {
                ForecastItem(
                    icon: "clock",
                    color: .blue,
                    title: "In 2 Hours",
                    description: impactAnalysis.shortTerm
                )
                
                ForecastItem(
                    icon: "calendar",
                    color: .purple,
                    title: "Tomorrow Morning",
                    description: impactAnalysis.midTerm
                )
                
                ForecastItem(
                    icon: "waveform.path.ecg",
                    color: .red,
                    title: "Long Term",
                    description: impactAnalysis.longTerm
                )
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct ForecastItem: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

extension Color {
    static let transparent = Color.black.opacity(0)
}

// MARK: - Preview
#Preview {
    let foodImagePath = Bundle.main.path(forResource: "food", ofType: "HEIC") ?? ""
    let foodImage = UIImage(contentsOfFile: foodImagePath) ?? UIImage(systemName: "photo")!
    
    return FoodAnalysisView(
        analysisData: FoodAnalysisData(
            foods: [
                FoodItem(name: "Mixed Lunch Plate", amountG: 300, cook: "Mixed")
            ],
            nutrition: Nutrition(
                energyKcal: 750,
                proteinG: 30,
                fatG: 25,
                carbG: 80,
                fiberG: 10,
                sodiumMg: 1200,
                sugarG: 5,
                satFatG: 8
            ),
            confidence: 0.95,
            isBalanced: false,
            nutritionSummary: "A varied meal providing sustained energy, but be mindful of potential high sodium content.",
            overallEvaluation: nil,
            impact: ImpactAnalysis(
                primaryText: "Preview primary text",
                shortTerm: "Energized and satiated, avoiding a post-meal slump.",
                midTerm: "Feeling normal and refreshed, though slight thirst possible if sodium intake was high.",
                longTerm: "Balanced diet contributes to long-term health.",
                riskTags: ["high_sodium"]
            )
        ),
        capturedImage: foodImage
    )
}
