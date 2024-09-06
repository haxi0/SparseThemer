//
//  ContentView.swift
//  POC
//
//  Created by haxi0 on 03.09.2024.
//

import SwiftUI

func parseAppsOutput(_ output: String) -> [String: String]? {
    var result: [String: String] = [:]
    
    // Removing brackets and splitting the entries
    let entries = output.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).components(separatedBy: ", ")
    
    // Iterating over each entry to split key-value pairs
    for entry in entries {
        let pair = entry.components(separatedBy: ": ")
        if pair.count == 2 {
            let key = pair[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let value = pair[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            result[key] = value
        }
    }
    
    return result
}

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
            Button("Automated Apps Patching (RISKY!)") {
                print("[*] Start")
            }
            
            Button("Automated Reddit Patch") {
                print("[*] Start")
                
                // Assuming restore.getApps() returns a Dictionary<String, String>
                let appsDictionary = restore.getApps()

                if !appsDictionary.isEmpty {
                    print("[*] Downloading .car")
                    
                    // Get the path for "com.reddit.Reddit"
                    if let redditPath = appsDictionary["com.reddit.Reddit"] {
                        print("[*] RedditApp path: \(redditPath)")

                        // Get the last path component
                        let lastPathComponent = (redditPath as NSString).lastPathComponent
                        print("[*] Last path component: \(lastPathComponent)")

                        // TODO: Unhardcode :troll:
                        if grabAssetsCar("https://iosapps.itunes.apple.com/itunes-assets/Purple211/v4/64/21/81/64218131-c1b9-1997-db1d-77c6b1137ffb/extDirgkfjetjcgxeyfbkm.lc.32375868113064696.D6OUVIFQ2FQCA.signed.dpkg.ipa?accessKey=1725657396_7823640340818317029_qnA4o3IYxtaWP6UhOExbFy92AgVGw64gXs9c2fEPljbfkicYPjMLvsJ8t9pUy5jEGu2Mm%2FJMXJCEJKk5XI4Kx9VeL0nhwojUHuYS9aewiqNUmgbQzAnqbiwcoHYwmuI78xC6VsO3wIBmPCR4c3WO66urukVuqYU6mTn0IVcjlSl8u2hoMeeyK16yCs4CeSAl%2F4g%2Bs%2BW3jwCIR6OFzXoJFUG5%2FDP7TW4c%2F732HebNNcgHxWP819CaNXLfjzh7BRI7", "RedditApp.app") {
                            print("[*] Replacing icons with selected png")
                            do {
                                try themer.replaceIcons(icon: selectedPng!, car: Bundle.main.resourceURL!.appendingPathComponent("assetbackups/RedditApp_ORIGINAL_ASSETS.car"))
                                restore.PerformRestore(appPath: lastPathComponent, carAssets: Bundle.main.resourcePath!.appending("/assetbackups/RedditApp_ORIGINAL_ASSETS.car"))
                            } catch {
                                print("[!] Failed to patch assets")
                            }
                        }
                    } else {
                        print("[!] com.reddit.Reddit path not found")
                    }
                } else {
                    print("[!] getApps is empty")
                }
            }


            .bold()
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
                //no
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
                    print(app_url)
                    if app_url == "N/A" {
                        print("Bruh")
                        return
                    }
                    usleep(50000)
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
