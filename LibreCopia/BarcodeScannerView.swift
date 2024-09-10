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
    @Binding var isPresentingScanner: Bool // Control the sheet dismissal

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        return cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let request = VNDetectBarcodesRequest { request, error in
                if let results = request.results as? [VNBarcodeObservation] {
                    for result in results {
                        if let payloadString = result.payloadStringValue {
                            print("Detected Barcode: \(payloadString)")
                            if self.isISBNBarcode(payloadString) {
                                DispatchQueue.main.async {
                                    // Set the detected ISBN and close the scanner
                                    self.parent.detectedISBN = payloadString
                                    self.parent.isPresentingScanner = false // Close the scanner sheet
                                }
                            }
                        }
                    }
                }
            }

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? requestHandler.perform([request])
        }

        // Helper function to check if the barcode is an ISBN
        private func isISBNBarcode(_ payload: String) -> Bool {
            return payload.hasPrefix("978") || payload.hasPrefix("979")
        }
    }
}
