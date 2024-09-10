//
//  ContentView.swift
//  LibreCopia
//
//  Created by Sal Olivares on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresentingScanner = false
    @State private var detectedISBN: String? = nil
    @State private var isScanning = false // To indicate the scanning process
    
    var body: some View {
        VStack {
            // Display the detected ISBN or a prompt if none detected yet
            if let isbn = detectedISBN {
                Text("Detected ISBN: \(isbn)")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
            } else {
                Text("No ISBN detected yet")
                    .font(.title)
                    .padding()
            }

            Button(action: {
                isPresentingScanner = true
                isScanning = true // Start scanning
            }) {
                Text("Open Camera")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $isPresentingScanner) {
                ZStack {
                    // Pass the detected ISBN and scanning status to the scanner view
                    BarcodeScannerView(detectedISBN: $detectedISBN, isPresentingScanner: $isPresentingScanner, isScanning: $isScanning)
                        .edgesIgnoringSafeArea(.all)
                    // Overlay on top of the camera view
                    ScannerOverlay()
                }
            }

            // Show scanning status
            if isScanning {
                Text("Scanning for ISBN...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}

#Preview {
    ContentView()
}
