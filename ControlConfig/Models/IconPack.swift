//
//  IconPack.swift
//  ControlConfig
//
//  Created by Vrishank Agarwal on 16/07/2023.
//

import Foundation
import ZIPFoundation

struct Icon: Codable {
    let source: String
    let sizeX: Int
    let sizeY: Int
    let padding: Int
}

struct ModuleIconSet: Codable {
    let main: Int
    let icons: [Icon]
}

struct IconPack: Codable {
    let name: String
    let type: String
    let udid: String
    let moduleIcons: [String: ModuleIconSet]
}

struct ExtractedIconPack {
    let pack: IconPack
    let assetsFolder: String
    var assetsFolderURL: URL {
        URL(fileURLWithPath: self.assetsFolder)
    }
}


class IconPackZipHelper {
    // Export IconPack to a zip file
    static func exportIconPack(_ iconPack: ExtractedIconPack, zipURL: URL) throws {
        //IconPack, assetsFolderURL: URL,
        // Create a temporary directory to store the files
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        // Write the IconPack JSON to pack.json
        let packJSONData = try JSONEncoder().encode(iconPack.pack)
        let packJSONURL = tempDirectoryURL.appendingPathComponent("pack.json")
        try packJSONData.write(to: packJSONURL)
        
        // Copy the assets folder to the temporary directory
        let assetsDestinationURL = tempDirectoryURL.appendingPathComponent("assets")
        try FileManager.default.copyItem(at: iconPack.assetsFolderURL, to: assetsDestinationURL)
        
        // Create a zip archive
        try FileManager.default.zipItem(at: tempDirectoryURL, to: zipURL)
        
        // Cleanup: remove the temporary directory
        try FileManager.default.removeItem(at: tempDirectoryURL)
    }
    
    // Import IconPack from a zip file
    static func importIconPack(from zipURL: URL, assetsFolder: String) throws -> ExtractedIconPack {
        // Create a temporary directory to extract the files
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        // Extract the zip archive
        try FileManager.default.unzipItem(at: zipURL, to: tempDirectoryURL)
        
        // Read the IconPack JSON from pack.json
        let packJSONURL = tempDirectoryURL.appendingPathComponent("pack.json")
        let packJSONData = try Data(contentsOf: packJSONURL)
        let iconPack = try JSONDecoder().decode(IconPack.self, from: packJSONData)
        let extractedPack = ExtractedIconPack(pack: iconPack, assetsFolder: assetsFolder)
        
        // Copy the assets folder to the specified destination
        let assetsSourceURL = tempDirectoryURL.appendingPathComponent("assets")
        try FileManager.default.copyItem(at: assetsSourceURL, to: extractedPack.assetsFolderURL)
        
        // Cleanup: remove the temporary directory
        try FileManager.default.removeItem(at: tempDirectoryURL)
        
        return extractedPack
    }
}
