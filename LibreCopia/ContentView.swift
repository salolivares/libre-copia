//
//  ContentView.swift
//  LibreCopia
//
//  Created by Sal Olivares on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresentingScanner = false
    @State private var detectedISBN: String? = nil // Store the detected ISBN

    var body: some View {
        VStack {
            // Display the detected ISBN or a prompt if none detected yet
            if let isbn = detectedISBN {
                Text("Detected ISBN: \(isbn)")
                    .font(.title)
                    .padding()
            } else {
                Text("No ISBN detected yet")
                    .font(.title)
                    .padding()
            }

            Button("Open Camera") {
                isPresentingScanner = true
            }
            .padding()
            .sheet(isPresented: $isPresentingScanner) {
                // Pass the detected ISBN to the scanner view
                BarcodeScannerView(detectedISBN: $detectedISBN, isPresentingScanner: $isPresentingScanner)
            }
        }
    }
}

#Preview {
    ContentView()
}
