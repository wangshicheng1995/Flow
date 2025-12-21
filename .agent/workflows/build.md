---
description: 编译 Flow iOS 项目
---

# Flow 项目编译指南

## 环境信息
- Xcode 版本: Xcode-26.1.0.app
- Xcode 路径: /Applications/Xcode-26.1.0.app
- 目标平台: iOS 26.1
- 可用模拟器: iPhone 17, iPhone 17 Pro, iPhone 17 Pro Max, iPhone Air, iPhone 16e

## 编译命令

### 1. 使用 iPhone 17 Pro 模拟器编译（推荐）
// turbo
```bash
DEVELOPER_DIR=/Applications/Xcode-26.1.0.app/Contents/Developer xcodebuild -scheme Flow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -100
```

### 2. 使用其他可用模拟器编译
```bash
# iPhone 17
DEVELOPER_DIR=/Applications/Xcode-26.1.0.app/Contents/Developer xcodebuild -scheme Flow -destination 'platform=iOS Simulator,name=iPhone 17' build

# iPhone 17 Pro Max
DEVELOPER_DIR=/Applications/Xcode-26.1.0.app/Contents/Developer xcodebuild -scheme Flow -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

# iPad Pro 13-inch (M5)
DEVELOPER_DIR=/Applications/Xcode-26.1.0.app/Contents/Developer xcodebuild -scheme Flow -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build
```

### 3. 清理后重新编译
```bash
DEVELOPER_DIR=/Applications/Xcode-26.1.0.app/Contents/Developer xcodebuild -scheme Flow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' clean build 2>&1 | tail -100
```

## 注意事项
1. 必须使用 `DEVELOPER_DIR` 环境变量指定 Xcode 路径，因为系统默认的 developer directory 是 Command Line Tools
2. 不要使用 iPhone 16，该模拟器在当前环境中不可用
3. 编译输出使用 `tail -100` 限制输出行数，避免日志过长
