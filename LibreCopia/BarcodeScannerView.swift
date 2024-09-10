//
//  BarcodeScannerView.swift
//  LibreCopia
//
//  Created by Sal Olivares on 9/10/24.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var detectedISBN: String?
    @Binding var isPresentingScanner: Bool
    @Binding var isScanning: Bool
    @Binding var showConfirmation: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        return cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if showConfirmation {
            uiViewController.freezeCamera()
        } else {
            uiViewController.unfreezeCamera()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard !parent.showConfirmation, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let request = VNDetectBarcodesRequest { request, error in
                if let results = request.results as? [VNBarcodeObservation] {
                    for result in results {
                        if let payloadString = result.payloadStringValue {
                            print("Detected Barcode: \(payloadString)")
                            if self.isISBNBarcode(payloadString) {
                                DispatchQueue.main.async {
                                    self.parent.detectedISBN = payloadString
                                    self.parent.showConfirmation = true
                                    self.parent.isScanning = false
                                }
                                return
                            }
                        }
                    }
                }
            }

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? requestHandler.perform([request])
        }

        private func isISBNBarcode(_ payload: String) -> Bool {
            return payload.hasPrefix("978") || payload.hasPrefix("979")
        }
    }
}

struct ScannerOverlay: View {
    @Binding var showConfirmation: Bool
    @Binding var detectedISBN: String?
    @Binding var isPresentingScanner: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
                .foregroundColor(.green)
                .frame(width: 300, height: 150)

            if showConfirmation {
                VStack {
                    Text("ISBN Detected: \(detectedISBN ?? "")")
                        .foregroundColor(.white)
                        .padding()
                    
                    HStack {
                        Button("Continue Scanning") {
                            showConfirmation = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Confirm") {
                            isPresentingScanner = false
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            } else {
                Text("Position the barcode within the box")
                    .foregroundColor(.white)
                    .padding(.top, 200)
            }
        }
    }
}
