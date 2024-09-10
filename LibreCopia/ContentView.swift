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
    @State private var isScanning = false
    @State private var showConfirmation = false
    
    var body: some View {
        VStack {
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
                isScanning = true
                detectedISBN = nil
                showConfirmation = false
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
                    BarcodeScannerView(detectedISBN: $detectedISBN, isPresentingScanner: $isPresentingScanner, isScanning: $isScanning, showConfirmation: $showConfirmation)
                        .edgesIgnoringSafeArea(.all)
                    ScannerOverlay(showConfirmation: $showConfirmation, detectedISBN: $detectedISBN, isPresentingScanner: $isPresentingScanner)
                }
            }

            if isScanning && !showConfirmation {
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
