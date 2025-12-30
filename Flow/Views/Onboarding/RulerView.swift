//
//  RulerView.swift
//  Flow
//
//  Created on 2025-12-29.
//

import SwiftUI

//
//  RulerView.swift
//  Flow
//
//  Created on 2025-12-29.
//

import SwiftUI
import UIKit

struct RulerView: UIViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double         // 这里的 step 是逻辑步进，比如 0.1 或 1
    let majorStep: Double    // 大刻度间隔，比如 1 或 10
    let scaleSize: CGFloat   // 视觉上每一格的像素宽度，比如 10pt
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.decelerationRate = .fast // 快速减速，更有刻度感
        
        // 构建刻度内容
        let rulerContent = RulerContentView(
            range: range,
            step: step,
            majorStep: majorStep,
            scaleSize: scaleSize
        )
        rulerContent.backgroundColor = .clear
        
        // 计算内容总宽度
        let totalSteps = Int((range.upperBound - range.lowerBound) / step)
        let contentWidth = CGFloat(totalSteps) * scaleSize
        rulerContent.frame = CGRect(x: 0, y: 0, width: contentWidth, height: 80)
        
        scrollView.addSubview(rulerContent)
        scrollView.contentSize = CGSize(width: contentWidth, height: 80)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // 设置所有 padding 使得首尾都能滚动到中间
        let padding = uiView.bounds.width / 2
        
        // 只有当contentInset发生变化时才更新（避免循环布局）
        if uiView.contentInset.left != padding {
            uiView.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        }
        
        // 初始定位或外部数值改变时同步滚动位置
        // 注意：为了避免手势冲突，只有在非拖拽状态下才更新 offset
        if !uiView.isDragging && !uiView.isDecelerating {
            let targetOffset = CGFloat(value - range.lowerBound) / step * scaleSize - padding
            
            // 只有差异较大时才滚动，避免浮点数抖动
            if abs(uiView.contentOffset.x - targetOffset) > 1 {
                uiView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: RulerView
        
        init(_ parent: RulerView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let padding = scrollView.contentInset.left
            let offsetX = scrollView.contentOffset.x + padding
            
            // 计算当前数值
            let index = Double(offsetX / parent.scaleSize)
            let rawValue = parent.range.lowerBound + index * parent.step
            
            // 限制范围
            let clampedValue = min(max(rawValue, parent.range.lowerBound), parent.range.upperBound)
            
            // 更新 Binding (避免过于频繁的主线程更新，可节流，但为了丝滑先直接更)
            if abs(parent.value - clampedValue) > (parent.step / 10) {
                DispatchQueue.main.async {
                    self.parent.value = clampedValue
                }
            }
        }
        
        // 增加吸附效果（可选）
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let padding = scrollView.contentInset.left
            let targetX = targetContentOffset.pointee.x + padding
            
            // 计算最近的刻度位置
            let index = round(targetX / parent.scaleSize)
            let snappedX = index * parent.scaleSize - padding
            
            targetContentOffset.pointee.x = snappedX
        }
    }
}

// 使用 UIKit 绘制刻度，性能极高
class RulerContentView: UIView {
    let range: ClosedRange<Double>
    let step: Double
    let majorStep: Double
    let scaleSize: CGFloat
    
    init(range: ClosedRange<Double>, step: Double, majorStep: Double, scaleSize: CGFloat) {
        self.range = range
        self.step = step
        self.majorStep = majorStep
        self.scaleSize = scaleSize
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        
        let totalSteps = Int((range.upperBound - range.lowerBound) / step)
        
        for i in 0...totalSteps {
            let currentValue = range.lowerBound + Double(i) * step
            let x = CGFloat(i) * scaleSize
            
            // 仅绘制在可视区域内的刻度（虽然 drawRect 已经裁剪了，但手动优化更佳）
            // 这里简单全绘，CoreGraphics 够快
            
            // 判断主刻度 (用 epsilon 避免浮点误差)
            let isMajor = abs(currentValue.remainder(dividingBy: majorStep)) < (step / 2)
            
            // 绘制线条
            if isMajor {
                context?.setStrokeColor(UIColor.systemGray.withAlphaComponent(0.6).cgColor)
                context?.move(to: CGPoint(x: x, y: rect.height))
                context?.addLine(to: CGPoint(x: x, y: rect.height - 30))
                
                // 绘制文字
                let text = "\(Int(currentValue))" as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.systemGray
                ]
                let textSize = text.size(withAttributes: attributes)
                text.draw(at: CGPoint(x: x - textSize.width / 2, y: rect.height - 50), withAttributes: attributes)
                
            } else {
                context?.setStrokeColor(UIColor.systemGray.withAlphaComponent(0.3).cgColor)
                context?.move(to: CGPoint(x: x, y: rect.height))
                context?.addLine(to: CGPoint(x: x, y: rect.height - 15))
            }
            
            context?.strokePath()
        }
    }
}

// SwiftUI 包装器：加上中间指示线和渐变遮罩
struct ScaleRulerWrapper: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let majorStep: Double
    let scaleSize: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            // 刻度尺本体
            RulerView(
                value: $value,
                range: range,
                step: step,
                majorStep: majorStep,
                scaleSize: scaleSize
            )
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.1),
                        .init(color: .black, location: 0.9),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // 指示针
            Rectangle()
                .fill(OnboardingDesign.accentColor)
                .frame(width: 3, height: 40)
                .cornerRadius(1.5)
                .offset(y: 16) // 对齐刻度线底部
        }
        .frame(height: 80)
    }
}
