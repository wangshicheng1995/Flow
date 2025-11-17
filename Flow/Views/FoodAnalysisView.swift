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
        GeometryReader { geometry in
            ZStack {
                // 背景色
                Color.black
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // ========================
                        // 顶部图片区域（占60%高度）
                        // ========================
                        ZStack(alignment: .bottom) {
                            Image(uiImage: capturedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                                .clipped()
                            
                            // 图片底部渐变遮罩
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0),
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)
                        }
                        .frame(height: geometry.size.height * 0.6)
                        
                        // ========================
                        // 磨砂信息卡片区域
                        // ========================
                        VStack(alignment: .leading, spacing: 0) {
                            // 主要信息区
                            VStack(alignment: .leading, spacing: 12) {
                                // 食物名称（大标题）
                                Text(analysisData.foodItems.joined(separator: "、"))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // 营养评价（副标题）
                                Text(analysisData.nutritionSummary)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // 置信度和均衡性标签
                                HStack(spacing: 12) {
                                    // 置信度标签
                                    Label {
                                        Text("\(Int(analysisData.confidence * 100))% 准确")
                                            .font(.system(size: 13, weight: .medium))
                                    } icon: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.white.opacity(0.7))
                                    
                                    // 营养均衡标签
                                    if analysisData.isBalanced {
                                        Label {
                                            Text("营养均衡")
                                                .font(.system(size: 13, weight: .medium))
                                        } icon: {
                                            Image(systemName: "leaf.fill")
                                                .font(.system(size: 12))
                                        }
                                        .foregroundColor(.green.opacity(0.9))
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 24)
                            
                            // 详细分析区域
                            VStack(alignment: .leading, spacing: 24) {
                                // 食物成分
                                AnalysisSectionView(
                                    title: "识别到的食物",
                                    items: analysisData.foodItems
                                )
                                
                                // 营养分析详情（可扩展更多内容）
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("营养分析")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(analysisData.nutritionSummary)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(6)
                                    
                                    // 可以在这里添加更多营养相关的详细信息
                                    // 例如：卡路里、蛋白质、碳水化合物等
                                }
                                
                                // 健康建议（示例内容）
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("健康建议")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("基于您的饮食分析，建议适量增加膳食纤维的摄入，可以搭配更多绿叶蔬菜。同时注意控制油脂摄入量。")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(6)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 100) // 底部留白，确保内容可以完全滚动
                        }
                        .frame(minHeight: geometry.size.height * 0.4)
                        .background(
                            // 磨砂玻璃效果背景
                            ZStack {
                                // 深色背景
                                Color(red: 0.1, green: 0.1, blue: 0.12)
                                
                                // 毛玻璃材质叠加
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            }
                        )
                    }
                }
                .ignoresSafeArea(.all)
            }
        }
    }
}

// MARK: - 分析区域组件
struct AnalysisSectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            // 食物标签网格
            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    FoodTagView(text: item)
                }
            }
        }
    }
}

// MARK: - 食物标签组件
struct FoodTagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
            )
    }
}

// MARK: - 流式布局（用于标签）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxX = max(maxX, currentX - spacing)
            }
            
            self.size = CGSize(width: maxX, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    // 加载项目中的 food.HEIC 图片作为预览
    let foodImagePath = Bundle.main.path(forResource: "food", ofType: "HEIC") ?? ""
    let foodImage = UIImage(contentsOfFile: foodImagePath) ?? UIImage(systemName: "photo")!
    
    return FoodAnalysisView(
        analysisData: FoodAnalysisData(
            foodItems: ["红烧肉", "蔬菜拼盘", "竹笋", "木耳"],
            confidence: 0.95,
            isBalanced: true,
            nutritionSummary: "这道菜品搭配了肉类和多种蔬菜，富含蛋白质和膳食纤维。红烧肉提供优质蛋白，蔬菜提供维生素和矿物质，营养较为均衡。"
        ),
        capturedImage: foodImage
    )
}
