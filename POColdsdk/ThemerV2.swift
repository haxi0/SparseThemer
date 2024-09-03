//
//  ThemerV2.swift
//  POC
//
//  Created by haxi0 on 03.09.2024.
//

import AssetCatalogWrapper
import CoreGraphics

enum ImageError: Error {
    case invalidImageData
    case unableToGetCGImage
    case invalidImageFormat
}

class Theme {
    static var shared = Theme()
    
    func replaceIcons() throws {
        let iconPath = URL(fileURLWithPath: "/Users/haxi0/Downloads/Spotify.png")
        let tempAssetDir = URL(fileURLWithPath: "/Users/haxi0/Downloads/Spotify.car")
        
        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: tempAssetDir)
        for rendition in renditionsRoot {
            let type = rendition.type
            guard type == .icon else { continue }
            let renditions = rendition.renditions
            for rend in renditions {
                do {
                    let imgData = try Data(contentsOf: iconPath)
                    
                    // Create a data provider from the image data
                    guard let dataProvider = CGDataProvider(data: imgData as CFData) else { throw ImageError.invalidImageData }
                    
                    // Create a CGImage from the data provider
                    guard let cgImage = CGImage(
                        pngDataProviderSource: dataProvider,  // Use pngDataProviderSource for PNG images
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent
                    ) else { throw ImageError.unableToGetCGImage }
                    
                    try catalog.editItem(rend, fileURL: tempAssetDir, to: .image(cgImage))
                } catch {
                    print("Error processing image: \(error)")
                }
            }
        }
    }
}
