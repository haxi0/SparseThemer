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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var apps: Dictionary<String, String> = Dictionary<String, String>()
    let themer = Theme.shared
    let restore = Restore.shared
    let ipatool = IPATool.shared
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
            }
            Button("Get apps") {
                apps = restore.getApps()
            }
            TextField("Enter username", text: $email)
            TextField("Enter password", text: $password)
            Button("Log in with ipatool to get assets") {
                for (bundleid, app_path) in apps {
                    let app_name = URL(string: app_path)!.lastPathComponent
                    let app_url = ipatool.getIPALinks(bundleID: bundleid, username: email, password: password)
                    if app_url == "N/A" {
                        print("Bruh")
                        return
                    }
                    grabAssetsCar(app_url, app_name)
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
