//
//  AccountView.swift
//  Flow
//
//  Created on 2025-11-14.
//

import SwiftUI

// MARK: - 账户详情页
struct AccountView: View {
    var body: some View {
        ZStack {
            // 背景颜色
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 用户信息卡片
                    UserProfileCard()

                    // 健康数据概览
                    HealthOverviewCard()

                    // 设置选项
                    SettingsSection()

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - 用户信息卡片
struct UserProfileCard: View {
    var body: some View {
        VStack(spacing: 20) {
            // 头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.7, blue: 0.2),
                                Color(red: 1.0, green: 0.6, blue: 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }

            // 用户名
            VStack(spacing: 8) {
                Text("Flow 用户")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("user@flow.app")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }

            // 编辑按钮
            Button(action: {
                // TODO: 编辑个人资料
            }) {
                Text("编辑个人资料")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - 健康数据概览卡片
struct HealthOverviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("健康概览")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            // 数据统计网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                HealthStatItem(title: "今日摄入", value: "1800", unit: "kcal", icon: "flame.fill", color: .orange)
                HealthStatItem(title: "分析次数", value: "23", unit: "次", icon: "chart.line.uptrend.xyaxis", color: .blue)
                HealthStatItem(title: "连续打卡", value: "7", unit: "天", icon: "calendar", color: .green)
                HealthStatItem(title: "健康评分", value: "85", unit: "分", icon: "star.fill", color: .yellow)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - 健康数据项
struct HealthStatItem: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - 设置选项区域
struct SettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("设置")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                SettingsRow(icon: "bell.fill", title: "通知设置", color: .purple)
                SettingsRow(icon: "chart.bar.fill", title: "数据与隐私", color: .blue)
                SettingsRow(icon: "info.circle.fill", title: "关于 Flow", color: .green)
                SettingsRow(icon: "arrow.right.circle.fill", title: "退出登录", color: .red)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - 设置行
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button(action: {
            // TODO: 处理设置选项点击
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Preview
#Preview {
    AccountView()
}
