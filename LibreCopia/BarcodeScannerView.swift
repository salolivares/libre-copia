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
                                    self.parent.detectedISBN = payloadString
                                    self.parent.isPresentingScanner = false
                                    self.parent.isScanning = false // Stop scanning after detection
                                }
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
    var body: some View {
        ZStack {
            // Create a rectangular overlay with transparency
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            // Define the scanning area (center box)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
                .foregroundColor(.green)
                .frame(width: 300, height: 150)

            Text("Position the barcode within the box")
                .foregroundColor(.white)
                .padding(.top, 200) // Adjust text position
        }
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerOverlay()
    }
}
