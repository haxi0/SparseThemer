//
//  ContentView.swift
//  POC
//
//  Created by haxi0 on 03.09.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isFileImporterPresented = false
    @State private var selectedCar: URL? = nil
    @State private var selectedPng: URL? = nil
    let themer = Theme.shared
    
    var body: some View {
        VStack {
            Button("Select .car & .png") {
                isFileImporterPresented = true
            }
            
            Button("Replace Images") {
                do {
                    try themer.replaceIcons(icon: selectedPng!, car: selectedCar!)
                } catch {
                    print("kys")
                }
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.item], // Adjust the allowed content types as needed
            onCompletion: { result in
                switch result {
                case .success(let url):
                    if url.lastPathComponent.contains(".car") {
                        selectedCar = url
                    } else if url.lastPathComponent.contains(".png") {
                        selectedPng = url
                    } else {
                        print("That's not a .car neither a .png file, silly")
                    }
                case .failure(let error):
                    print("Failed to select file: \(error.localizedDescription)")
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
