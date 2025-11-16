# Flow App - SwiftUI 项目开发指南

## 项目概述

Flow 是一款健康预警和行动建议的美食拍照分析 App,采用 SwiftUI 开发。核心功能包括:
- 食物拍照识别与营养分析
- 个性化健康预测和风险评估
- 具象化健康影响可视化(如面部浮肿、脂肪肝风险)
- 健康货币游戏化系统
- 社交对比功能

## 代码开发规范

### 代码风格
- 使用 Swift 5.9+ 语法特性
- 优先使用 SwiftUI 声明式语法,避免 UIKit 混用
- 遵循 Swift API Design Guidelines
- 使用有意义的中文命名(变量、函数、注释),便于团队理解
- 视图拆分原则:单个视图文件不超过 200 行,超过则拆分为子视图
- 使用 `// MARK: -` 分隔代码逻辑区块

### 架构原则
- 采用 MVVM 架构模式
- ViewModel 负责业务逻辑,View 仅负责 UI 渲染
- 使用 `@Observable` 宏(iOS 17+)或 `ObservableObject` 管理状态
- 网络请求统一封装在 Service 层
- 使用 Repository 模式隔离数据源

### 模块化
- 核心功能模块:
  - `FoodRecognition`: 食物识别
  - `HealthAnalysis`: 健康分析
  - `Visualization`: 健康影响可视化
- 每个模块包含独立的 Views/ViewModels/Services

## AI 代码验收流程

### 第一步:语法与静态检查
**目标**: 确保代码可编译,无明显语法错误

```bash
# 编译检查(不运行)
xcodebuild -scheme Flow -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' clean build

# 或使用 Swift 编译器直接检查
swiftc -typecheck Sources/**/*.swift
```

**验收清单**:
- [ ] 代码可成功编译,无 error
- [ ] Warning 数量未增加(或有合理解释)
- [ ] 无未使用的 import
- [ ] 无未使用的变量或函数(除 Preview)
- [ ] 所有 `@State`/`@Binding`/`@Observable` 正确标注
- [ ] 闭包循环引用已使用 `[weak self]` 或 `[unowned self]` 处理

### 第二步:上下文影响分析
**目标**: 确保修改不破坏现有功能

**检查要点**:
1. **接口变更影响**
   - 如修改 ViewModel 的 public 方法,检查所有调用此 ViewModel 的 View
   - 如修改数据模型,检查所有使用该模型的视图和逻辑
   
2. **状态管理影响**
   - 检查新增的 `@State` 是否正确传递给子视图
   - 检查 `@Binding` 双向绑定是否符合预期
   - 确认环境对象 `@EnvironmentObject` 已在父视图注入

3. **导航流影响**
   - 如修改导航逻辑,测试完整导航路径(返回、跳转)
   - 确认 NavigationStack/NavigationPath 状态正确管理

**验收操作**:
```bash
# 使用 grep 查找方法调用
grep -r "functionName" Sources/

# 查找数据模型使用
grep -r "ModelName" Sources/
```

### 第三步:运行时验证
**目标**: 确保程序可正常运行

```bash
# 在模拟器中运行
xcodebuild -scheme Flow -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build run

# 或直接使用 Xcode
# 打开 Flow.xcodeproj,点击运行按钮
```

**验收清单**:
- [ ] App 可成功启动,无 crash
- [ ] 新增功能页面可正常打开
- [ ] 新增功能核心交互可用(点击、输入、导航)
- [ ] 无明显 UI 布局问题(文字截断、重叠、越界)
- [ ] 暗黑模式下 UI 显示正常
- [ ] 不同设备尺寸下布局自适应正常(iPhone SE / iPhone 15 Pro Max / iPad)

**如果无法完整运行主程序,使用以下降级测试**:
1. **SwiftUI Preview 测试**
   ```swift
   #Preview {
       YourNewView()
           .environmentObject(MockViewModel())
   }
   ```
   - 使用 Mock 数据验证视图渲染
   - 在 Xcode Canvas 中预览

2. **单元测试**
   ```bash
   xcodebuild test -scheme FlowTests -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

3. **快照测试**(可选)
   - 对新增视图生成快照,对比布局差异

### 第四步:功能完整性验证
**目标**: 确保新功能符合需求

**核心功能验收**:
- **食物识别**: 
  - [ ] 相机可正常调用
  - [ ] 图片可成功上传
  - [ ] API 调用返回识别结果
  - [ ] 识别结果正确展示
  
- **健康分析**:
  - [ ] 营养数据计算准确
  - [ ] 健康预警逻辑正确触发
  - [ ] 预警信息清晰展示

- **视觉化展示**:
  - [ ] 图表渲染流畅
  - [ ] 动画效果自然
  - [ ] 数据更新及时

**边界情况测试**:
- [ ] 网络请求失败处理(显示错误提示)
- [ ] 空数据状态展示(Empty State)
- [ ] 加载状态展示(Loading Indicator)
- [ ] 大数据量性能(列表滚动流畅性)

### 第五步:性能与优化检查
**目标**: 确保代码性能可接受

```bash
# 使用 Instruments 检测性能
# 在 Xcode 中: Product > Profile > Time Profiler
```

**检查要点**:
- [ ] 无主线程阻塞(网络请求已放入后台)
- [ ] 图片加载使用异步缓存
- [ ] 列表使用 `LazyVStack` 实现懒加载
- [ ] 无内存泄漏(闭包循环引用)
- [ ] 视图刷新频率合理(避免过度重绘)

### 第六步:代码质量检查
**目标**: 保持代码可维护性

**人工审查清单**:
- [ ] 代码逻辑清晰,易于理解
- [ ] 关键业务逻辑有中文注释说明
- [ ] 复杂算法有注释说明原理
- [ ] 硬编码值提取为常量
- [ ] 重复代码已提取为函数/视图
- [ ] 错误处理完善(try-catch 或 Result 类型)

**可选工具**:
```bash
# SwiftLint 静态代码检查
swiftlint lint --path Sources/

# SwiftFormat 代码格式化
swiftformat Sources/
```

## 常用命令

### 构建与运行
```bash
# 清理构建
xcodebuild clean -scheme Flow

# 编译项目
xcodebuild -scheme Flow -sdk iphonesimulator build

# 运行单元测试
xcodebuild test -scheme FlowTests -destination 'platform=iOS Simulator,name=iPhone 15'

# 运行 UI 测试
xcodebuild test -scheme FlowUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 代码检查
```bash
# SwiftLint 检查
swiftlint

# 查找 TODO/FIXME
grep -rn "TODO\|FIXME" Sources/

# 检查未使用的 import
swiftc -typecheck Sources/**/*.swift 2>&1 | grep "warning: unused import"
```

### 依赖管理
```bash
# 更新 Swift Package 依赖
xcodebuild -resolvePackageDependencies

# 清理 SPM 缓存
rm -rf ~/Library/Caches/org.swift.swiftpm
```

## 特定场景验收

### 网络请求代码
- [ ] API 端点 URL 正确
- [ ] 请求 Header 包含必要信息(如 API Key)
- [ ] 请求体 JSON 格式正确
- [ ] 响应解析使用 Codable,字段映射正确
- [ ] 错误处理覆盖:网络错误、解析错误、业务错误
- [ ] 超时设置合理(建议 30 秒)

### 相机功能代码
- [ ] Info.plist 包含相机权限说明(NSCameraUsageDescription)
- [ ] 权限请求逻辑正确
- [ ] 权限拒绝时有友好提示
- [ ] 拍照后图片正确处理(压缩、旋转)
- [ ] 内存管理正确(图片用完释放)

### 数据持久化代码
- [ ] UserDefaults 使用场景合理(仅小数据)
- [ ] CoreData/SwiftData 模型定义正确
- [ ] 数据迁移策略(如模型变更)
- [ ] 数据读写在后台线程

## 开发建议

### 优先级原则
1. **功能完整性** > 代码优雅性
2. **用户体验** > 技术实现难度
3. **核心功能稳定** > 辅助功能丰富

### 渐进式开发
- 先实现核心功能主流程
- 再完善边界情况处理
- 最后优化性能和细节

### Mock 数据策略
- 开发初期使用 Mock 数据,不依赖后端
- Mock 数据结构需与真实 API 一致
- 预留 Mock/真实数据切换开关

## 常见问题排查

### 编译失败
1. 清理 Build Folder: Xcode > Product > Clean Build Folder
2. 删除 DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. 重新打开项目

### 运行 Crash
1. 检查 Console 日志
2. 查看 Crash 堆栈
3. 使用断点调试

### 布局异常
1. 使用 Debug View Hierarchy
2. 检查约束冲突
3. 验证数据源

## 提交前最终检查

- [ ] 代码已通过所有验收步骤
- [ ] 无 console 警告或错误
- [ ] 新增功能已手动测试
- [ ] 代码格式化完成
- [ ] 提交信息清晰描述改动

---

**记住**: AI 生成的代码不是最终产品,而是开发的起点。每次生成后认真验收,才能保证长期高效交付。
