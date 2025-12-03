//
//  ThemeSelectionView.swift
//  Flow
//
//  Created on 2025-12-14.
//

import SwiftUI

struct ThemeSelectionView: View {
    @AppStorage(ThemePreference.storageKey) private var storedPreference = ThemePreference.system.rawValue

    private var selectedPreference: ThemePreference {
        ThemePreference.resolve(storedPreference)
    }

    var body: some View {
        List {
            ForEach(ThemePreference.allCases) { option in
                Button {
                    storedPreference = option.rawValue
                } label: {
                    HStack {
                        Text(option.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if option == selectedPreference {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("深色模式")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThemeSelectionView()
    }
}
