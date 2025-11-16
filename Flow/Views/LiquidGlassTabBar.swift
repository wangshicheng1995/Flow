//
//  LiquidGlassTabBar.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - Tab Item 定义
enum TabItem {
    case summary
    case photo
    case history

    var title: String {
        switch self {
        case .summary:
            return "Summary"
        case .photo:
            return "Photo"
        case .history:
            return "History"
        }
    }

    var icon: String {
        switch self {
        case .summary:
            return "chart.bar.doc.horizontal"
        case .photo:
            return "camera"
        case .history:
            return "clock"
        }
    }
}
