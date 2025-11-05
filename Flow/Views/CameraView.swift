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
        setupCamera()
        setupCaptureButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            return
        }

        session.addInput(input)

        let output = AVCapturePhotoOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        self.photoOutput = output
        self.captureSession = session

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        self.previewLayer = previewLayer
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
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }

        delegate?.didCaptureImage(image)
    }
}
