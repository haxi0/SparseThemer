import SwiftUI
import Foundation
import AppKit

class Logger: ObservableObject {
    @Published var logs: [String] = []
    
    func log(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
        }
    }
}

func getApplicationSupportDirectory() -> URL {
    let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let directoryPath = appSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "MyApp")
    
    try? FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
    
    return directoryPath
}


func parseAppsOutput(_ output: String) -> [String: String]? {
    var result: [String: String] = [:]
    let entries = output.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).components(separatedBy: ", ")
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
    @State private var selectedFolder: URL? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @ObservedObject private var logger = Logger()

    let themer = Theme.shared
    let restore = Restore.shared
    let ipatool = IPATool.shared
    
    var body: some View {
        VStack {
            if !email.isEmpty && !password.isEmpty {
                Button("Restore apps") {
                    Task {
                        await restoreApps()
                    }
                }
                
                Button("Theme User Apps") {
                    Task {
                        await themeUserApps()
                    }
                }
                .padding()
                .bold()
            }
            
            TextField("Enter username", text: $email)
            TextField("Enter password", text: $password)
            
            // Button to select a custom theme folder
            Button("Select Custom Theme Folder") {
                isFileImporterPresented = true
            }
            .padding()

            // Check if a custom theme folder is selected
            if let selectedFolder = selectedFolder {
                Text("Selected Theme Folder: \(selectedFolder.path)")
                    .foregroundColor(.green)
            } else {
                Text("No Theme Folder Selected")
                    .foregroundColor(.red)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(logger.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black)
            }
            .frame(height: 200)
            .padding(.top, 20)
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.folder, .png, .data, .directory],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    if url.hasDirectoryPath {
                        selectedFolder = url
                        logger.log("Selected folder: \(url.path)")
                    } else if url.lastPathComponent.contains(".car") {
                        selectedCar = url
                    } else if url.lastPathComponent.contains(".png") {
                        selectedPng = url
                    } else {
                        logger.log("That's not a .car neither a .png file, silly")
                    }
                case .failure(let error):
                    logger.log("Failed to select file: \(error.localizedDescription)")
                }
            }
        )
    }
    
    private func restoreApps() async {
        let appsDictionary = await restore.getApps()
        if !appsDictionary.isEmpty {
            logger.log("[*] Downloading .car files for all apps.")
            var assetsDictionary = [String: String]()
            
            for (bundleid, app_path) in appsDictionary {
                let app_name = URL(string: app_path)!.lastPathComponent
                let appBackupPath = getApplicationSupportDirectory().appendingPathComponent("assetbackups/\(app_name)_ORIGINAL_ASSETS.car")
                if FileManager.default.fileExists(atPath: appBackupPath.path) {
                    logger.log("File already exists at \(appBackupPath). Skipping download.")
                } else {
                    let app_url = await ipatool.getIPALinks(bundleID: bundleid, username: email, password: password)
                    if app_url == "N/A" {
                        logger.log("Bruh")
                        return
                    }
                    await grabAssetsCar(app_url, app_name)
                }
            }
            
            for (bundleID, appPath) in appsDictionary {
                logger.log("[*] Processing app: \(bundleID)")
                let appName = URL(fileURLWithPath: appPath).lastPathComponent
                let appBackupPath = getApplicationSupportDirectory().appendingPathComponent("assetbackups/\(appName)_ORIGINAL_ASSETS.car")
                
                logger.log("[*] App name: \(appName)")
                logger.log("[*] Backup path: \(appBackupPath)")
                
                if FileManager.default.fileExists(atPath: appBackupPath.path) {
                    logger.log("[*] Found backup file: \(appBackupPath.path)")
                    assetsDictionary[appName] = appBackupPath.path
                } else {
                    logger.log("[!] No backup file found for \(bundleID).")
                }
            }
            
            await restore.PerformRestoreMultipleAssets(assetsDictionary: assetsDictionary)
            logger.log("[*] No way, it worked?")
        } else {
            logger.log("[!] getApps is empty.")
        }
    }
    
    private func themeUserApps() async {
        let appsDictionary = await restore.getApps()
        
        if !appsDictionary.isEmpty {
            logger.log("[*] Downloading .car files for all apps.")
            var assetsDictionary = [String: String]()
            
            for (bundleid, app_path) in appsDictionary {
                let app_name = URL(string: app_path)!.lastPathComponent
                let appBackupPath = getApplicationSupportDirectory().appendingPathComponent("assetbackups/\(app_name)_ORIGINAL_ASSETS.car")
                if FileManager.default.fileExists(atPath: appBackupPath.path) {
                    logger.log("File already exists at \(appBackupPath). Skipping download.")
                } else {
                    let app_url = await ipatool.getIPALinks(bundleID: bundleid, username: email, password: password)
                    if app_url == "N/A" {
                        logger.log("Bruh")
                        return
                    }
                    await grabAssetsCar(app_url, app_name)
                }
            }
            
            for (bundleID, appPath) in appsDictionary {
                logger.log("[*] Processing app: \(bundleID)")
                let appName = URL(fileURLWithPath: appPath).lastPathComponent
                let appBackupPath = getApplicationSupportDirectory().appendingPathComponent("assetbackups/\(appName)_ORIGINAL_ASSETS.car")
                let moddedAppPath = getApplicationSupportDirectory().appendingPathComponent("assetbackups/\(appName)_MODDED_ASSETS.car")
                
                logger.log("[*] App name: \(appName)")
                logger.log("[*] Backup path: \(appBackupPath)")
                
                if FileManager.default.fileExists(atPath: appBackupPath.path) {
                    logger.log("[*] Found backup file: \(appBackupPath.path)")
                    
                    let iconFileName = "\(bundleID)-large.png"
                    let iconFolderPath = selectedFolder ?? Bundle.main.resourceURL!.appendingPathComponent("icons")
                    let iconPath = iconFolderPath.appendingPathComponent(iconFileName)
                    
                    if FileManager.default.fileExists(atPath: iconPath.path) {
                        logger.log("[*] Replacing icons with \(iconFileName)")
                        
                        do {
                            try themer.replaceIcons(icon: iconPath, car: appBackupPath)
                            assetsDictionary[appName] = moddedAppPath.path
                            logger.log("[*] Patched assets for \(bundleID).")
                        } catch {
                            logger.log("[!] Failed to patch assets for \(bundleID). Error: \(error)")
                        }
                    } else {
                        logger.log("[!] Icon file \(iconFileName) not found.")
                    }
                } else {
                    logger.log("[!] No backup file found for \(bundleID).")
                }
            }
            
            restore.PerformRestoreMultipleAssets(assetsDictionary: assetsDictionary)
            logger.log("[*] No way, it worked?")
        } else {
            logger.log("[!] getApps is empty.")
        }
    }
}
