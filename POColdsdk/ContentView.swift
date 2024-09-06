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
            Button("Automated Reddit Patch (PLIST)") {
                print("[*] Start")
                
                let appsDictionary = restore.getApps()
                
                if !appsDictionary.isEmpty {
                    if let redditPath = appsDictionary["com.reddit.Reddit"] {
                        print("[*] Downloading Info.plist")
                        
                        let app_name = "RedditApp.app"
                        let app_url = ipatool.getIPALinks(bundleID: "com.reddit.Reddit", username: email, password: password)
                        if app_url == "N/A" {
                            print("Bruh")
                            return
                        }
                        usleep(5000)
                        grabInfoPlist(app_url, app_name)
                        
                        print("[*] Assuming that the Info.plist has already downloaded, lets patch it.")
                        
                        let plistPath = Bundle.main.resourcePath!.appending("/assetbackups/RedditApp.app_ORIGINAL_INFO.plist")
                        
                        if let plistData = FileManager.default.contents(atPath: plistPath),
                           var plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
                            
                            print("[*] Loaded plist.")
                            
                            if var iconsDict = plist["CFBundleIcons"] as? [String: Any],
                               var primaryIconDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any] {
                                
                                primaryIconDict["CFBundleIconName"] = "icon"
                                
                                primaryIconDict["CFBundleIconFiles"] = ["icon", "icon@2x", "icon@3x"]
                                
                                iconsDict["CFBundlePrimaryIcon"] = primaryIconDict
                                plist["CFBundleIcons"] = iconsDict
                                
                                if let updatedPlistData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) {
                                    try? updatedPlistData.write(to: URL(fileURLWithPath: plistPath))
                                    print("[*] Plist updated successfully.")
                                } else {
                                    print("[!] Failed to serialize updated plist data.")
                                }
                            } else {
                                print("[!] CFBundlePrimaryIcon key not found in CFBundleIcons.")
                            }
                        } else {
                            print("[!] Failed to load the plist file.")
                        }
                        
                        print("[*] Start Copying Icons")
                        // idk if you should resize them but im lazy to do that
                        let lastPathComponent = (redditPath as NSString).lastPathComponent
                        print("[*] Last path component: \(lastPathComponent)")
                        
                        restore.PerformRestorePlist(appPath: lastPathComponent, infoPlist: Bundle.main.resourcePath!.appending("/assetbackups/RedditApp.app_ORIGINAL_INFO.plist"))
                        restore.PerformRestoreIcons(appPath: lastPathComponent, appIcon: selectedPng!.path())
                        restore.PerformRestoreIcons2x(appPath: lastPathComponent, appIcon: selectedPng!.path())
                        restore.PerformRestoreIcons3x(appPath: lastPathComponent, appIcon: selectedPng!.path())
                    }
                }
            }
            .bold()
            
            
            Button("Automated Reddit Patch") {
                print("[*] Start")
                
                // Assuming restore.getApps() returns a Dictionary<String, String>
                let appsDictionary = restore.getApps()
                
                if !appsDictionary.isEmpty {
                    print("[*] Downloading .car")
                    
                    // Get the path for "com.reddit.Reddit"
                    if let redditPath = appsDictionary["com.reddit.Reddit"] {
                        print("[*] RedditApp path: \(redditPath)")
                        
                        let app_name = "RedditApp.app"
                        let app_url = ipatool.getIPALinks(bundleID: "com.reddit.Reddit", username: email, password: password)
                        if app_url == "N/A" {
                            print("Bruh")
                            return
                        }
                        usleep(5000)
                        grabAssetsCar(app_url, app_name)
                        
                        // Get the last path component
                        let lastPathComponent = (redditPath as NSString).lastPathComponent
                        print("[*] Last path component: \(lastPathComponent)")
                        
                        // TODO: Unhardcode :troll:
                        print("[*] Replacing icons with selected .png.")
                        do {
                            try themer.replaceIcons(icon: selectedPng!, car: Bundle.main.resourceURL!.appendingPathComponent("/assetbackups/RedditApp.app_ORIGINAL_ASSETS.car"))
                            restore.PerformRestoreCar(appPath: lastPathComponent, car: Bundle.main.resourcePath!.appending("/assetbackups/RedditApp.app_ORIGINAL_ASSETS.car"))
                        } catch {
                            print("[!] Failed to patch assets.")
                        }
                    } else {
                        print("[!] com.reddit.Reddit path not found.")
                    }
                } else {
                    print("[!] getApps is empty.")
                }
            }
            .bold()
            
            Button("Select .car & .png") {
                isFileImporterPresented = true
            }
            /*
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
             */
            Button("Get apps") {
                apps = restore.getApps()
            }
            TextField("Enter username", text: $email)
            TextField("Enter password", text: $password)
            Button("Log in with ipatool to get info") {
                for (bundleid, app_path) in apps {
                    let app_name = URL(string: app_path)!.lastPathComponent
                    let app_url = ipatool.getIPALinks(bundleID: bundleid, username: email, password: password)
                    if app_url == "N/A" {
                        print("Bruh")
                        return
                    }
                    usleep(5000)
                    //                    grabAssetsCar(app_url, app_name)
                    grabInfoPlist(app_url, app_name)
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
