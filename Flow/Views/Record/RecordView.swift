//
//  RecordView.swift
//  Flow
//
//  主记录页面：相机预览 + 相册入口 + 文本输入 + 上传分析
//

import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - 记录模式枚举
enum RecordMode: String, CaseIterable {
    case camera = "拍照"
    case text = "输入"
}

// MARK: - 主记录视图
struct RecordView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.selectedTab) private var selectedTab
    @State private var showCenterHint = false
    @State private var hintDismissTask: Task<Void, Never>?
    @EnvironmentObject private var stressScoreViewModel: StressScoreViewModel
    
    // 当前记录模式
    @State private var currentMode: RecordMode = .camera
    
    // ⭐️ 分析流程状态
    @State private var showAnalyzingView = false      // 是否显示分析等待页
    @State private var pendingImage: UIImage?         // 待分析的图片
    @State private var analysisResult: FoodAnalysisData?  // 分析结果
    @State private var showFoodAnalysis = false       // 是否显示分析结果页
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色
                Color.black
                    .ignoresSafeArea()
                
                // 根据模式显示不同内容
                switch currentMode {
                case .camera:
                    CameraContentView(
                        viewModel: viewModel,
                        showCenterHint: $showCenterHint,
                        currentMode: $currentMode,
                        geometry: geometry,
                        onImageCaptured: { image in
                            // 拍照后开始分析流程
                            Task {
                                await startImageAnalysis(image: image)
                            }
                        }
                    )
                case .text:
                    TextInputContentView(currentMode: $currentMode)
                }
            }
        }
        .alert("分析失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
        // ⭐️ 分析等待页面（AnalyzingView）- 纯 UI 展示
        .fullScreenCover(isPresented: $showAnalyzingView) {
            if let image = pendingImage {
                AnalyzingView(
                    capturedImage: image,
                    onDismiss: {
                        // 用户取消，返回拍照页面
                        showAnalyzingView = false
                        pendingImage = nil
                    }
                )
            }
        }
        // ⭐️ 分析结果页面（FoodNutritionalView）
        .fullScreenCover(isPresented: $showFoodAnalysis) {
            if let result = analysisResult, let image = pendingImage {
                FoodNutritionalView(analysisData: result, capturedImage: image)
            }
        }
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
                // 相册选择的图片也走分析流程
                if let item = viewModel.selectedPhotoItem {
                    do {
                        guard let imageData = try await item.loadTransferable(type: Data.self),
                              let image = UIImage(data: imageData) else {
                            return
                        }
                        viewModel.selectedPhotoItem = nil
                        // 开始分析流程
                        await startImageAnalysis(image: image)
                    } catch {
                        print("❌ 加载图库照片失败")
                    }
                }
            }
        }
        .onAppear {
            viewModel.stressScoreRefresher = {
                await stressScoreViewModel.refreshScore()
            }
            if currentMode == .camera {
                triggerCenterHint()
            }
        }
        .onDisappear {
            hintDismissTask?.cancel()
            hintDismissTask = nil
            showCenterHint = false
        }
        .onChange(of: selectedTab.wrappedValue) { _, newValue in
            if newValue == .camera && currentMode == .camera {
                triggerCenterHint()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    @MainActor
    private func triggerCenterHint() {
        hintDismissTask?.cancel()
        showCenterHint = true
        
        hintDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeOut) {
                showCenterHint = false
            }
        }
    }
    
    // MARK: - 图片分析流程
    /// 开始图片分析流程：显示等待页面 -> 发起网络请求 -> 处理结果 -> 保存图片到本地
    @MainActor
    private func startImageAnalysis(image: UIImage) async {
        // 1. 先设置图片并显示等待页面
        pendingImage = image
        showAnalyzingView = true
        
        // 2. 发起网络请求
        do {
            print("📤 RecordView: 开始上传图片...")
            let result = try await RecordService.shared.uploadImage(image)
            print("✅ RecordView: 分析完成，返回 \(result.foods.count) 种食物")
            
            // 3. ⭐️ 保存图片到本地
            do {
                let (mealId, _) = try MealImageStorage.shared.saveImageWithTimestamp(image)
                print("💾 RecordView: 图片已保存到本地，mealId: \(mealId)")
            } catch {
                // 图片保存失败不影响主流程，仅打印日志
                print("⚠️ RecordView: 图片保存失败 - \(error.localizedDescription)")
            }
            
            // 4. 请求成功，保存结果并关闭等待页
            analysisResult = result
            showAnalyzingView = false
            
            // 5. 延迟显示结果页，确保动画流畅
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 秒
            showFoodAnalysis = true
            
            // 6. 刷新压力分数
            await stressScoreViewModel.refreshScore()
            
        } catch {
            print("❌ RecordView: 分析失败 - \(error.localizedDescription)")
            
            // 请求失败，显示错误并关闭等待页
            showAnalyzingView = false
            pendingImage = nil
            
            if let apiError = error as? APIError {
                viewModel.errorMessage = apiError.localizedDescription
            } else {
                viewModel.errorMessage = "图片分析失败，请重试"
            }
            viewModel.showError = true
        }
    }
}

// MARK: - 顶部导航栏


// MARK: - 相机内容视图
private struct CameraContentView: View {
    @Bindable var viewModel: HomeViewModel
    @Binding var showCenterHint: Bool
    @Binding var currentMode: RecordMode
    let geometry: GeometryProxy
    
    // ⭐️ 拍照完成回调
    var onImageCaptured: ((UIImage) -> Void)?
    
    // ⭐️ 正圆尺寸：直径为屏幕宽度的百分比（调整这个值可改变透明圆的大小）
    private var circleSize: CGFloat {
        geometry.size.width * 0.9  // 👈 修改这个数值：0.8 = 80%, 0.9 = 90%, 1.0 = 100%
    }
    
    // ⭐️ 正圆垂直偏移：负数向上，正数向下
    private var circleOffsetY: CGFloat {
        -75  // 👈 修改这个数值：-20 = 向上 20pt, 20 = 向下 20pt
    }
    
    var body: some View {
        ZStack {
            // ═══════════════════════════════════════════════════════════
            // 第一层：全屏相机预览
            // ═══════════════════════════════════════════════════════════
            CameraPreviewView(
                capturedImage: .constant(nil),
                onImageCaptured: { image in
                    // 使用新的回调，如果有的话
                    if let callback = onImageCaptured {
                        callback(image)
                    } else {
                        // 兼容旧逻辑
                        viewModel.handleCapturedImage(image)
                    }
                }
            )
            .ignoresSafeArea()
            
            // ═══════════════════════════════════════════════════════════
            // 第二层：正圆形遮罩（周围半透明灰，中间透明正圆）
            // ═══════════════════════════════════════════════════════════
            Rectangle()
                .fill(Color.black.opacity(0.45))
                .mask(
                    CircleHoleMask(circleSize: circleSize, offsetY: circleOffsetY)
                        .fill(style: FillStyle(eoFill: true))
                )
                .ignoresSafeArea()
            
            // ═══════════════════════════════════════════════════════════
            // 第三层：UI 控件层
            // ═══════════════════════════════════════════════════════════
            VStack {
                // 顶部导航栏
                RecordHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                
                Spacer()
                
                // 中心提示文字
                if showCenterHint {
                    Text("请将相机对准您的食物")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                        .offset(y: circleSize / 2 + 30) // 在圆形下方
                }
                
                Spacer()
                
                // ═══════════════════════════════════════════════════════════
                // 底部控制栏（带逆圆角背景）
                // ═══════════════════════════════════════════════════════════
                ZStack(alignment: .top) {
                    // 深色背景 + 逆圆角
                    BottomBarBackground(cornerRadius: 24)
                        .fill(Color(red: 37/255, green: 38/255, blue: 38/255)) // #252626
                        .frame(height: 185)  // ⭐️ 底部控制栏背景高度（修改这个值可调整高度）
                        .ignoresSafeArea(edges: .bottom)
                    
                    // 控制按钮
                    CameraBottomButtonsView(
                        viewModel: viewModel,
                        currentMode: $currentMode
                    )
                    .padding(.horizontal, 40)
                    .padding(.top, 50)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 正圆形镂空蒙版
private struct CircleHoleMask: Shape {
    let circleSize: CGFloat
    let offsetY: CGFloat  // 垂直偏移量
    
    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        
        // 正圆位置：居中 + 垂直偏移
        let circleRect = CGRect(
            x: rect.midX - circleSize / 2,
            y: rect.midY - circleSize / 2 + offsetY,
            width: circleSize,
            height: circleSize
        )
        path.addPath(Circle().path(in: circleRect))
        return path
    }
}

// MARK: - 底部控制栏背景（带逆圆角）
/// 逆圆角效果：在左上和右上角外侧形成凹陷，让上方区域看起来有圆角
private struct BottomBarBackground: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 从左边最上方开始（左侧"耳朵"的顶点）
        path.move(to: CGPoint(x: 0, y: -cornerRadius))
        
        // 左边向下到圆弧起点
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        // 左上角逆圆角：从左边缘向内凹进的圆弧
        path.addArc(
            center: CGPoint(x: cornerRadius, y: 0),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        
        // 顶边向右
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: cornerRadius))
        
        // 右上角逆圆角：向内凹进的圆弧
        path.addArc(
            center: CGPoint(x: rect.width - cornerRadius, y: 0),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )
        
        // 右边向上到"耳朵"顶点
        path.addLine(to: CGPoint(x: rect.width, y: -cornerRadius))
        
        // 右边向下到底部
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // 底边向左
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        // 闭合路径
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 顶部导航栏
private struct RecordHeaderView: View {
    @Environment(\.selectedTab) private var selectedTab
    
    var body: some View {
        HStack(alignment: .center) {
            // 左侧关闭按钮（X 图标）
            Button(action: {
                selectedTab.wrappedValue = .today
            }) {
                CircleButtonLabel(iconName: "xmark")
            }
            
            Spacer()
            
            // 右侧闪光灯按钮
            Button(action: {
                // TODO: 闪光灯切换功能
            }) {
                CircleButtonLabel(iconName: "bolt.slash")
            }
        }
    }
}

// 通用圆形按钮样式
private struct CircleButtonLabel: View {
    let iconName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15)) // 半透明背景
                .frame(width: 44, height: 44)
            
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - 相机底部按钮
private struct CameraBottomButtonsView: View {
    @Bindable var viewModel: HomeViewModel
    @Binding var currentMode: RecordMode
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 左侧相册按钮（三等分之一）
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                VStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("相册")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
            }
            
            // 中间拍照按钮（三等分之一）
            CaptureButton()
                .frame(maxWidth: .infinity)
            
            // 右侧输入按钮（三等分之一）
            Button(action: {
                withAnimation(.spring(duration: 0.3)) {
                    currentMode = .text
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("输入")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - 拍照按钮（SwiftUI 实现）
private struct CaptureButton: View {
    var body: some View {
        Button(action: {
            // 发送拍照通知
            NotificationCenter.default.post(name: .capturePhoto, object: nil)
        }) {
            ZStack {
                // 外圈白色描边
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 76, height: 76)
                
                // 内圈白色实心（与外圈之间有深色间隙）
                Circle()
                    .fill(Color.white)
                    .frame(width: 62, height: 62)
            }
        }
    }
}

// MARK: - 文本输入内容视图
private struct TextInputContentView: View {
    @Environment(\.selectedTab) private var selectedTab
    @Binding var currentMode: RecordMode
    @State private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // 背景（模糊的灰色效果）
            LinearGradient(
                colors: [
                    Color.gray.opacity(0.4),
                    Color.gray.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部占位（为导航栏留空）
                Spacer()
                    .frame(height: 80)
                
                // 输入卡片区域
                VStack(spacing: 0) {
                    // 拖动指示条
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    
                    // 文本输入区域
                    TextEditor(text: $inputText)
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 200)
                        .padding(.horizontal, 20)
                        .overlay(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("输入你所吃的食物，例如：2个鸡蛋，一片面包，1个牛油果")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 24)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .onAppear {
            // 自动聚焦输入框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("确定") {
                    submitText()
                }
                .fontWeight(.semibold)
            }
        }
        // 顶部导航栏覆盖（文本输入模式下的特殊导航栏）
        .overlay(alignment: .top) {
            TextInputHeaderView(currentMode: $currentMode)
                .padding(.horizontal, 20)
                .padding(.top, 12)
        }
    }
    
    private func submitText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 打印用户输入的文本到控制台
        print("📝 用户输入的食物描述: \(inputText)")
        
        // 隐藏键盘
        isTextFieldFocused = false
        
        // TODO: 后续传入 upload 接口
    }
}

// MARK: - 文本输入模式的顶部导航栏
private struct TextInputHeaderView: View {
    @Environment(\.selectedTab) private var selectedTab
    @Binding var currentMode: RecordMode
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 左侧关闭按钮
            Button(action: {
                // 返回到 HomeView
                selectedTab.wrappedValue = .today
            }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // 中间切换器 - Describe / Enter kcal（暂不实现切换功能）
            HStack(spacing: 0) {
                Text("Describe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8))
                    )
                
                Text("Enter kcal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            }
            .padding(4)
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.15))
            )
            
            Spacer()
            
            // 右侧占位（保持对称）
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Loading Overlay View
private struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("正在分析食物...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

// MARK: - 拍照通知
extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

// MARK: - Camera Preview View (UIViewControllerRepresentable)
struct CameraPreviewView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraPreviewView
        
        init(_ parent: CameraPreviewView) {
            self.parent = parent
        }
        
        func didCaptureImage(_ image: UIImage) {
            parent.capturedImage = image
            parent.onImageCaptured(image)
        }
    }
}

// MARK: - Camera View Controller Delegate
protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
}

// MARK: - Camera View Controller
class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private let sessionQueue = DispatchQueue(label: "com.flow.camera.session")
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionConfigured = false
    private var shouldRunSession = false
    private var captureObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        
        // 监听拍照通知
        captureObserver = NotificationCenter.default.addObserver(
            forName: .capturePhoto,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.capturePhoto()
        }
    }
    
    deinit {
        if let observer = captureObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.shouldRunSession = true
            self.startSessionLocked()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.shouldRunSession = false
            self.stopSessionLocked()
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ 无法获取摄像头")
                self.captureSession.commitConfiguration()
                return
            }
            
            guard let input = try? AVCaptureDeviceInput(device: camera) else {
                print("❌ 无法创建摄像头输入")
                self.captureSession.commitConfiguration()
                return
            }
            
            guard self.captureSession.canAddInput(input) else {
                print("❌ 无法添加摄像头输入")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(input)
            
            let output = AVCapturePhotoOutput()
            guard self.captureSession.canAddOutput(output) else {
                print("❌ 无法添加照片输出")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
            
            self.photoOutput = output
            self.isSessionConfigured = true
            
            DispatchQueue.main.async {
                if self.previewLayer == nil {
                    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = self.view.bounds
                    self.view.layer.insertSublayer(previewLayer, at: 0)
                    self.previewLayer = previewLayer
                } else {
                    self.previewLayer?.session = self.captureSession
                }
                
                print("✅ 相机设置完成")
            }
            
            if self.shouldRunSession {
                self.startSessionLocked()
            }
        }
    }
    
    private func capturePhoto() {
        guard let photoOutput = photoOutput else {
            print("❌ 照片输出未初始化")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        print("📸 开始拍照")
    }
    
    private func startSessionLocked() {
        guard shouldRunSession else { return }
        
        guard isSessionConfigured else {
            print("⏳ 相机会话配置中，等待启动")
            return
        }
        
        if !captureSession.isRunning {
            captureSession.startRunning()
            print("✅ 相机会话已启动")
        }
    }
    
    private func stopSessionLocked() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        print("🛑 相机会话已停止")
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ 拍照错误: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ 无法处理照片数据")
            return
        }
        
        print("✅ 照片拍摄成功，尺寸: \(image.size)")
        delegate?.didCaptureImage(image)
    }
}

// MARK: - Preview
#Preview {
    RecordView()
        .environmentObject(StressScoreViewModel())
}
