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
}

class Theme {
    static var shared = Theme()
    
    func replaceIcons(icon: URL, car: URL) throws {
        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: car)
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
                    
                    try catalog.editItem(rend, fileURL: car, to: .image(cgImage))
                } catch {
                    print("Error processing image: \(error)")
                }
            }
        }
    }
}