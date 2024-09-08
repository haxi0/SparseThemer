//
//  ThemerV2.swift
//  POC
//
//  Created by haxi0 on 03.09.2024.
//

import AssetCatalogWrapper
import CoreGraphics
import PythonKit

let sys = Python.import("sys")

enum ImageError: Error {
    case invalidImageData
    case unableToGetCGImage
}

class Theme {
    static var shared = Theme()
    
    func replaceIcons(icon: URL, car: URL) throws {
        let originalPath = car.path
        let moddedPath = originalPath.replacingOccurrences(of: "ORIGINAL_ASSETS.car", with: "MODDED_ASSETS.car")
        let moddedURL = URL(fileURLWithPath: moddedPath)
        
        let fileManager = FileManager.default
        try fileManager.copyItem(at: car, to: moddedURL)
        
        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: moddedURL)
        for rendition in renditionsRoot {
            let type = rendition.type
            guard type == .icon else { continue }
            let renditions = rendition.renditions
            for rend in renditions {
                do {
                    let imgData = try Data(contentsOf: icon)
                    
                    guard let dataProvider = CGDataProvider(data: imgData as CFData) else { throw ImageError.invalidImageData }
                    
                    guard let cgImage = CGImage(
                        pngDataProviderSource: dataProvider,
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent
                    ) else { throw ImageError.unableToGetCGImage }
                    
                    try catalog.editItem(rend, fileURL: moddedURL, to: .image(cgImage))
                } catch {
                    print("Error processing image: \(error)")
                }
            }
        }
    }
}

class Restore {
    static var shared = Restore()
    static var dirPath = Bundle.main.path(forResource: "sparserestore", ofType:nil)!
    init() {
        print("Python \(sys.version_info.major).\(sys.version_info.minor)")
        print(sys.path)
        sys.path.append(Restore.dirPath)
    }
    func PerformRestoreCar(appPath: String, car: String) {
        let restorer = Python.import("restorer")
        restorer.restore_assetsCar(appPath, car)
    }
    func PerformRestorePlist(appPath: String, infoPlist: String) {
        let restorer = Python.import("restorer")
        restorer.restore_assetsPlist(appPath, infoPlist)
    }
    func PerformRestoreIcons(appPath: String, appIcon: String) {
        let restorer = Python.import("restorer")
        restorer.restore_assetsIcon(appPath, appIcon)
    }
    func PerformRestoreIcons2x(appPath: String, appIcon: String) {
        let restorer = Python.import("restorer")
        restorer.restore_assetsIcon2x(appPath, appIcon)
    }
    func PerformRestoreIcons3x(appPath: String, appIcon: String) {
        let restorer = Python.import("restorer")
        restorer.restore_assetsIcon3x(appPath, appIcon)
    }
    func getApps() -> Dictionary<String, String> {
        let restorer = Python.import("restorer")
        print(Dictionary<String, String>(restorer.get_apps())!)
        return Dictionary<String, String>(restorer.get_apps())!
    }
}
