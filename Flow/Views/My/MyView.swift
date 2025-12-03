//
//  MyView.swift
//  Flow
//
//  Created on 2025-12-03.
//

import SwiftUI

struct MyView: View {
    var body: some View {
        NavigationStack {
            List {
                // Section 1: Personalization
                Section(header: Text("界面与显示")) {
                    NavigationLink {
                        ThemeSelectionView()
                    } label: {
                        SettingsRow(title: "深色模式", showsChevron: false)
                    }
//                    SettingsRow(icon: "heart.text.square", title: "心率区间")
//                    SettingsRow(icon: "gearshape.fill", title: "设置")
                }
                
                // Section 2: Need Help?
//                Section(header: Text("需要帮助吗?")) {
//                    SettingsRow(icon: "sparkles", title: "提示和技巧")
//                    SettingsRow(icon: "questionmark.circle.fill", title: "常见问题解答")
//                    SettingsRow(icon: "envelope.fill", title: "联系我们")
//                }
                
                // Section 3: Follow Us
//                Section(header: Text("关注我们")) {
//                    SettingsRow(icon: "book.closed.fill", title: "小红书", isLink: true)
//                    SettingsRow(icon: "message.fill", title: "微信: GentlerStreak", showCopy: true)
//                    SettingsRow(icon: "camera.fill", title: "Instagram", isLink: true)
//                    SettingsRow(icon: "bird.fill", title: "Bluesky", isLink: true) // SF Symbols might not have butterfly, using bird or similar
//                    SettingsRow(icon: "ant.fill", title: "Reddit", isLink: true)
//                }
                
                // Section 4: Other
                Section {
                    SettingsRow(title: "撰写评价", isLink: true)
                    SettingsRow(title: "推荐 Flow")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsRow: View {
    let title: String
    var isLink: Bool = false
    var showCopy: Bool = false
    var showsChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            if showCopy {
                Button(action: {
                    UIPasteboard.general.string = title.components(separatedBy: ": ").last
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
            } else if isLink {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MyView()
}
