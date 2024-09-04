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
    let restore = Restore.shared
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
            Button("Try restoring") {
                restore.PerformRestore()
                restore.getApps()
            }
            Button("Try downloading reddit car") {
                grabAssetsCar("https://iosapps.itunes.apple.com/itunes-assets/Purple211/v4/64/21/81/64218131-c1b9-1997-db1d-77c6b1137ffb/extDirgkfjetjcgxeyfbkm.lc.32375868113064696.D6OUVIFQ2FQCA.signed.dpkg.ipa?accessKey=1725657396_7823640340818317029_qnA4o3IYxtaWP6UhOExbFy92AgVGw64gXs9c2fEPljbfkicYPjMLvsJ8t9pUy5jEGu2Mm%2FJMXJCEJKk5XI4Kx9VeL0nhwojUHuYS9aewiqNUmgbQzAnqbiwcoHYwmuI78xC6VsO3wIBmPCR4c3WO66urukVuqYU6mTn0IVcjlSl8u2hoMeeyK16yCs4CeSAl%2F4g%2Bs%2BW3jwCIR6OFzXoJFUG5%2FDP7TW4c%2F732HebNNcgHxWP819CaNXLfjzh7BRI7", "RedditApp")
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
