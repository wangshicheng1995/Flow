//
//  CameraView.swift
//  Flow
//
//  Created on 2025-11-05.
//

import SwiftUI
import AVFoundation

// MARK: - Camera View
struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var capturedImage: UIImage?
    let onImageCaptured: (UIImage) -> Void

    var body: some View {
        ZStack {
            // 相机预览
            CameraPreviewView(capturedImage: $capturedImage, onImageCaptured: onImageCaptured)
                .ignoresSafeArea()

            // 顶部关闭按钮
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)

                    Spacer()
                }

                Spacer()
            }
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

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureButton: UIButton!

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
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    private func setupCamera() {
        // 在后台线程配置相机会话
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .photo

            // 获取后置摄像头
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ 无法获取摄像头")
                session.commitConfiguration()
                return
            }

            // 创建输入
            guard let input = try? AVCaptureDeviceInput(device: camera) else {
                print("❌ 无法创建摄像头输入")
                session.commitConfiguration()
                return
            }

            guard session.canAddInput(input) else {
                print("❌ 无法添加摄像头输入")
                session.commitConfiguration()
                return
            }

            session.addInput(input)

            // 创建照片输出
            let output = AVCapturePhotoOutput()
            guard session.canAddOutput(output) else {
                print("❌ 无法添加照片输出")
                session.commitConfiguration()
                return
            }

            session.addOutput(output)
            session.commitConfiguration()

            self.photoOutput = output
            self.captureSession = session

            // 在主线程添加预览图层
            DispatchQueue.main.async {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = self.view.bounds
                self.view.layer.insertSublayer(previewLayer, at: 0)
                self.previewLayer = previewLayer
                
                print("✅ 相机设置完成")
            }
        }
    }

    private func setupCaptureButton() {
        // 创建拍照按钮
        captureButton = UIButton(type: .system)
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        // 外圈白色圆环
        let outerCircle = UIView()
        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        outerCircle.backgroundColor = .clear
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.layer.borderWidth = 4
        outerCircle.layer.cornerRadius = 40
        outerCircle.isUserInteractionEnabled = false

        // 内圈白色实心圆
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

    private func startSession() {
        guard let session = captureSession else {
            print("❌ 相机会话未初始化")
            return
        }
        
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                print("✅ 相机会话已启动")
            }
        }
    }

    private func stopSession() {
        guard let session = captureSession else { return }
        
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
                print("🛑 相机会话已停止")
            }
        }
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
    CameraView { image in
        print("Preview: 捕获图片，尺寸: \(image.size)")
    }
}
