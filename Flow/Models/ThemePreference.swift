//
//  ThemePreference.swift
//  Flow
//
//  Created on 2025-12-14.
//

import SwiftUI

enum ThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "flow.colorSchemePreference"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "跟随系统"
        case .light:
            return "普通模式"
        case .dark:
            return "深色模式"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    static func resolve(_ value: String) -> ThemePreference {
        ThemePreference(rawValue: value) ?? .system
    }
}
