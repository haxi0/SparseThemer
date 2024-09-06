//
//  IPALinkScraper.swift
//  POColdsdk
//
//  Created by LL on 9/4/24.
//
import Foundation
import PythonKit
// Idea: We have a list of all our user apps. Get their bundle id, then search up their download links.
// After that, use pzb to get their assets.car.
// Store the original as hashmap<bundleid, <bundleid>_original_assets.car>
// Make a new copy with hashmap<bundleid, <bundleid>_TWEAKED_assets.car>

//ipatool.py --json lookup -b com.reddit.Reddit -c US download  --appleid 'appleid' -p 'password' -> this will error out the first time, get the user to enter the 2fa code -> -p 'password'+'2fa'
struct AppInfo: Codable {
    let appName: String
    let appBundleId: String
    let downloadURL: String
}

func parseJSONAndGetDownloadLink(jsonString: String) -> String? {
    // Convert the JSON string to Data
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Failed to convert string to data")
        return nil
    }
    
    // Create a JSONDecoder instance
    let decoder = JSONDecoder()
    
    do {
        // Attempt to decode the JSON data into our AppInfo struct
        let appInfo = try decoder.decode(AppInfo.self, from: jsonData)
        
        // Return the download URL
        return appInfo.downloadURL
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

class IPATool {
    static var shared = IPATool()
    static var dirPath = Bundle.main.path(forResource: "assetgrabber/ipatool-py", ofType:nil)!
    init() {
        sys.path.append(IPATool.dirPath)
    }
    func getIPALinks(bundleID: String, username: String, password: String) -> String {
        let restorer = Python.import("main")
        sys.argv = []
        sys.argv.append("--json")
        sys.argv.append("lookup")
        sys.argv.append("--bundle-id")
        sys.argv.append(bundleID)
        sys.argv.append("-c")
        sys.argv.append("SG")
        sys.argv.append("download")
        sys.argv.append("--appleid")
        sys.argv.append(username)
        sys.argv.append("--password")
        sys.argv.append(password)
//        --json lookup -b com.reddit.Reddit -c US download --appleid 'leonghongkit@gmail.com' -p ''
//        do {
//            return try parseJSONAndGetDownloadLink(jsonString: String(restorer.main().throwing.dynamicallyCall(withArguments: []))!) ?? "N/A"
//        } catch {
//            print(error)
//            print("Enter password again with 2fa")
//        }
//        return "N/A"
        return parseJSONAndGetDownloadLink(jsonString: String(restorer.main())!)!
//        print(restorer.main())
//        return String(restorer.main())!
    }
//        .from_env.throwing.dynamicallyCall(withArguments: [])
}
