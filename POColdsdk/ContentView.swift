//
//  ContentView.swift
//  POC
//
//  Created by haxi0 on 03.09.2024.
//

import SwiftUI
import Foundation
import AppKit

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

func resizeImage(image: NSImage, targetSize: NSSize) -> NSImage? {
    let newImage = NSImage(size: targetSize)
    newImage.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: targetSize),
               from: NSRect(origin: .zero, size: image.size),
               operation: .sourceOver,
               fraction: 1.0)
    newImage.unlockFocus()
    return newImage
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
            if !email.isEmpty && !password.isEmpty && !((selectedPng?.description.isEmpty) == nil) {
                Button("AUTOMATED ALL APPS PATCH (RISKY!!!)") {
                    print("[*] Okay.. Here we go. You're on your own now.")
                    
                    let appsDictionary = restore.getApps()
                    
                    if !appsDictionary.isEmpty {
                        for (bundleid, app_path) in appsDictionary {
                            let app_name = URL(string: app_path)!.lastPathComponent
                            let app_url = ipatool.getIPALinks(bundleID: bundleid, username: email, password: password)
                            if app_url == "N/A" {
                                print("Bruh")
                                return
                            }
                            usleep(5000)
                            //                    grabAssetsCar(app_url, app_name)
                            grabAssetsCar(app_url, app_name)
                        }
                    }
                }
                .padding()
                .bold()
                Button("Automated Reddit Patch (PLIST)") {
                    print("[*] Start")
                    
                    let appsDictionary = restore.getApps()
                    
                    if !appsDictionary.isEmpty {
                        if let redditPath = appsDictionary["com.reddit.Reddit"] {
                            let lastPathComponent = (redditPath as NSString).lastPathComponent
                            print("[*] Last path component: \(lastPathComponent)")
                            
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
                                    
                                    primaryIconDict.removeValue(forKey: "CFBundleIconName")
                                    
                                    primaryIconDict["CFBundleIconFiles"] = ["icon.png", "icon@2x.png", "icon@3x.png"]
                                    
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
                            
                            print("[*] Resizing Icons")
                            // Maybe move do to the beginning of the function?
                            do {
                                let fileManager = FileManager.default
                                
                                // Copy items to the backup directory
                                try fileManager.copyItem(at: selectedPng!, to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon.png"))
                                try fileManager.copyItem(at: selectedPng!, to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon@2x.png"))
                                try fileManager.copyItem(at: selectedPng!, to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon@3x.png"))
                                
                                // Load the original image
                                if let originalImage = NSImage(contentsOf: selectedPng!) {
                                    // Resize images
                                    let icon = resizeImage(image: originalImage, targetSize: NSSize(width: 60, height: 60))
                                    let icon2x = resizeImage(image: originalImage, targetSize: NSSize(width: 120, height: 120))
                                    let icon3x = resizeImage(image: originalImage, targetSize: NSSize(width: 180, height: 180))
                                    
                                    // Save resized images to the respective paths
                                    if let iconData = icon?.tiffRepresentation,
                                       let icon2xData = icon2x?.tiffRepresentation,
                                       let icon3xData = icon3x?.tiffRepresentation {
                                        
                                        try iconData.write(to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon.png"))
                                        try icon2xData.write(to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon@2x.png"))
                                        try icon3xData.write(to: Bundle.main.resourceURL!.appendingPathComponent("\(lastPathComponent)_icon@3x.png"))
                                        
                                        print("[*] Icons resized successfully.")
                                    } else {
                                        print("[*] Failed to convert images to data.")
                                    }
                                } else {
                                    print("[*] Failed to load original image.")
                                }
                            } catch {
                                print("[*] Failed to resize icons. Error: \(error)")
                            }
                            
                            print("[*] Start Copying Icons")
                            restore.PerformRestorePlist(appPath: lastPathComponent, infoPlist: Bundle.main.resourcePath!.appending("/assetbackups/RedditApp.app_ORIGINAL_INFO.plist"))
                            restore.PerformRestoreIcons(appPath: lastPathComponent, appIcon: Bundle.main.resourcePath!.appending("/\(lastPathComponent)_icon.png"))
                            restore.PerformRestoreIcons2x(appPath: lastPathComponent, appIcon: Bundle.main.resourcePath!.appending("/\(lastPathComponent)_icon@2x.png"))
                            restore.PerformRestoreIcons3x(appPath: lastPathComponent, appIcon: Bundle.main.resourcePath!.appending("/\(lastPathComponent)_icon@3x.png"))
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
            }
            
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
            /*
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
             */
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
