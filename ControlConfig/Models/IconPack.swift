//
//  IconPack.swift
//  ControlConfig
//
//  Created by f1shy-dev on 16/07/2023.
//

import Foundation
import ZIPFoundation

struct CARIcon: Codable {
    let sourceFile: String
    let sizeX: Int
    let sizeY: Int
    let padding: Int
}

struct CAMLIcon: Codable {
    let indexCAMLFile: String
    let mainXMLFile: String
}

enum Icon: Codable {
    case caml(CAMLIcon)
    case car(CARIcon)
    
    enum CodingKeys: CodingKey {
        case caml
        case car
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .caml(let camlIcon):
            try container.encode(camlIcon, forKey: .caml)
        case .car(let carIcon):
            try container.encode(carIcon, forKey: .car)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let camlIcon = try container.decodeIfPresent(CAMLIcon.self, forKey: .caml) {
            self = .caml(camlIcon)
        } else if let carIcon = try container.decodeIfPresent(CARIcon.self, forKey: .car) {
            self = .car(carIcon)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .caml, in: container, debugDescription: "Invalid Icon type")
        }
    }
}

struct ModuleIconSet: Codable {
    let moduleFileName: String
    let mainVariant: Int
    let icons: [Icon]
}

struct IconPack: Codable {
    var id: String { bundleID }
    let bundleID: String
    let name: String
    let publisher: String?
    let moduleIcons: [String: ModuleIconSet]
}

struct ExtractedIconPack: Codable {
    let isImported: Bool
    var pack: IconPack
    let extractedFolder: URL
    var assetsFolder: URL {
        self.extractedFolder.appendingPathComponent("assets")
    }
    
    init(isImported: Bool, extractedFolder: URL) throws {
        self.isImported = isImported
        self.extractedFolder = extractedFolder
        
        let packJSONURL = extractedFolder.appendingPathComponent("pack.json")
        let packJSONData = try Data(contentsOf: packJSONURL)
        self.pack = try JSONDecoder().decode(IconPack.self, from: packJSONData)
    }
    
    enum CodingKeys: CodingKey {
        case isImported
        case extractedFolder
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isImported = try container.decode(Bool.self, forKey: .isImported)
        self.extractedFolder = try container.decode(URL.self, forKey: .extractedFolder)
        
        let packJSONURL = extractedFolder.appendingPathComponent("pack.json")
        let packJSONData = try Data(contentsOf: packJSONURL)
        self.pack = try JSONDecoder().decode(IconPack.self, from: packJSONData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isImported, forKey: .isImported)
        try container.encode(self.extractedFolder, forKey: .extractedFolder)
        
        let packJSONData = try JSONEncoder().encode(self.pack)
        let packJSONURL = extractedFolder.appendingPathComponent("pack.json")
        try packJSONData.write(to: packJSONURL)
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
        
        try FileManager.default.copyItem(at: iconPack.assetsFolder, to: tempDirectoryURL.appendingPathComponent("assets"))
        try FileManager.default.zipItem(at: tempDirectoryURL, to: zipURL)
        try FileManager.default.removeItem(at: tempDirectoryURL)
    }
    
    // Import IconPack from a zip file
    static func importIconPack(from zipURL: URL) throws -> ExtractedIconPack {
        // Create a temporary directory to extract the files
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        let iconPackFolderURL =  URL.documents.appendingPathComponent("icon_packs")
        if !FileManager.default.fileExists(atPath: iconPackFolderURL.path) {
            try FileManager.default.createDirectory(at: iconPackFolderURL, withIntermediateDirectories: true)
        }
    
        
        // Extract the zip archive
        try FileManager.default.unzipItem(at: zipURL, to: tempDirectoryURL)
        
        // Read the IconPack JSON from pack.json
        let packJSONURL = tempDirectoryURL.appendingPathComponent("pack.json")
        let packJSONData = try Data(contentsOf: packJSONURL)
        let iconPack = try JSONDecoder().decode(IconPack.self, from: packJSONData)
        let extractionFolder = iconPackFolderURL.appendingPathComponent(iconPack.bundleID)
        if FileManager.default.fileExists(atPath: extractionFolder.path) {
            throw "Icon pack already exists..."
        }
        let extractedPack = try ExtractedIconPack(isImported: true, extractedFolder: extractionFolder)

        try FileManager.default.copyItem(at: tempDirectoryURL, to: extractedPack.extractedFolder)
        
        try FileManager.default.removeItem(at: tempDirectoryURL)
        return extractedPack
    }
}
