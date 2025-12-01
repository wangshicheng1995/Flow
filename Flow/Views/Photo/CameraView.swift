//
//  CameraView.swift
//  Flow
//
//  主拍照页面：相机预览 + 相册入口 + 上传分析
//

import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - 主拍照视图
struct CameraView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.selectedTab) private var selectedTab
    @State private var showCenterHint = false
    @State private var hintDismissTask: Task<Void, Never>?
    @EnvironmentObject private var stressScoreViewModel: StressScoreViewModel

    var body: some View {
        ZStack {
            CameraPreviewView(
                capturedImage: .constant(nil),
                onImageCaptured: { image in
                    viewModel.handleCapturedImage(image)
                }
            )
            .ignoresSafeArea()

            VStack {
                HeaderView()
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()
            }

            VStack {
                Spacer()

                BottomButtonsView(viewModel: viewModel)
                    .padding(.bottom, 40)
            }

            if showCenterHint {
                Text("请将相机对准您的食物")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }

            if viewModel.isAnalyzing {
                LoadingOverlayView()
            }
        }
        .alert("分析失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
        .fullScreenCover(isPresented: $viewModel.showAnalysisResult) {
            if let analysis = viewModel.analysisResult, let image = viewModel.capturedImage {
                FoodAnalysisView(analysisData: analysis, capturedImage: image)
            } else {
                Text("未找到分析结果")
                    .font(.headline)
                    .padding()
            }
        }
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
        .onAppear {
            viewModel.stressScoreRefresher = {
                await stressScoreViewModel.refreshScore()
            }
            triggerCenterHint()
        }
        .onDisappear {
            hintDismissTask?.cancel()
            hintDismissTask = nil
            showCenterHint = false
        }
        .onChange(of: selectedTab.wrappedValue) { _, newValue in
            if newValue == .camera {
                triggerCenterHint()
            }
        }
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
}

// MARK: - Header View
private struct HeaderView: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Flow")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - 相册入口
private struct BottomButtonsView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        HStack {
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 72, height: 72)

                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
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
    private var captureButton: UIButton!
    private var isSessionConfigured = false
    private var shouldRunSession = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupCaptureButton()
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

    private func setupCaptureButton() {
        captureButton = UIButton(type: .system)
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        let outerCircle = UIView()
        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        outerCircle.backgroundColor = .clear
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.layer.borderWidth = 4
        outerCircle.layer.cornerRadius = 40
        outerCircle.isUserInteractionEnabled = false

        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 32
        innerCircle.isUserInteractionEnabled = false

        view.addSubview(captureButton)
        captureButton.addSubview(outerCircle)
        captureButton.addSubview(innerCircle)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80),

            outerCircle.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            outerCircle.widthAnchor.constraint(equalToConstant: 80),
            outerCircle.heightAnchor.constraint(equalToConstant: 80),

            innerCircle.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 64),
            innerCircle.heightAnchor.constraint(equalToConstant: 64)
        ])

        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        print("✅ 拍照按钮已设置")
    }

    @objc private func capturePhoto() {
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
    CameraView()
        .environmentObject(StressScoreViewModel())
}
