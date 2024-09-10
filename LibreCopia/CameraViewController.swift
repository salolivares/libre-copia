//
//  CameraViewController.swift
//  LibreCopia
//
//  Created by Sal Olivares on 9/10/24.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    var lastCapturedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // Setup camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        // Setup video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        }

        // Setup live preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)

        // Start the capture session
        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    func freezeCamera() {
        captureSession.stopRunning()
        if let image = lastCapturedImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = view.bounds
            view.addSubview(imageView)
        }
    }

    func unfreezeCamera() {
        view.subviews.forEach { if $0 is UIImageView { $0.removeFromSuperview() } }
        captureSession.startRunning()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let delegate = delegate {
            delegate.captureOutput?(output, didOutput: sampleBuffer, from: connection)
        }
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                lastCapturedImage = UIImage(cgImage: cgImage)
            }
        }
    }
}
