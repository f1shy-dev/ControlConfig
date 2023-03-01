//
//  Module.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Foundation

class Module: Identifiable, CustomStringConvertible, Codable, ObservableObject, Equatable {
    var id: String { fileName }
    var fileName: String

    var isDefaultModule: Bool

    static func ==(lhs: Module, rhs: Module) -> Bool {
        return lhs.fileName == rhs.fileName
    }

    init(fileName: String) {
        self.fileName = fileName

        let dmsDict = NSDictionary(contentsOfFile: CCMappings().dmsPath)
//        print("dms-reader-called")
        let fileDict = NSDictionary(contentsOfFile: "\(CCMappings.bundlesPath)\(fileName)/Info.plist")
        let bundleID = "\(fileDict?["CFBundleIdentifier"] ?? "com.what.unknown")"

        self.isDefaultModule = dmsDict?.allKeys.contains(where: { key in
            bundleID == "\(key)"
        }) == true
    }

    var sfIcon: String {
        if let icon = CCMappings().bundleIDBasedSFIcons[bundleID] {
            return "\(icon)"
        }
        return "app.dashed"
    }

    var bundleID: String {
        let fileDict = NSDictionary(contentsOfFile: "\(CCMappings.bundlesPath)\(fileName)/Info.plist")
        return "\(fileDict?["CFBundleIdentifier"] ?? "com.what.unknown")"
    }

    var sizesInDMSFile: [String] {
        let dmsDict = PlistHelpers.plistToDict(path: CCMappings().dmsPath)
        if dmsDict?.allKeys.contains(where: { key in
            bundleID == "\(key)"
        }) == true {
            if let module = dmsDict?[bundleID] {
                print(PlistHelpers.getKeys(from: module as! [String: Any]))
            }
        }
        return []
    }

    var description: String {
        let fileDict = NSDictionary(contentsOfFile: "\(CCMappings.bundlesPath)\(fileName)/Info.plist")

        if let setName = CCMappings.bundleIDBasedModuleNameOverrides[bundleID] {
            return "\(setName)"
        }

        let name = "\(fileDict?["CFBundleDisplayName"] ?? fileDict?["CFBundleName"] ?? "Unknown Module")"
        return name.components(separatedBy: "Module").first ?? name
    }

    enum CodingKeys: String, CodingKey {
        case fileName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileName = try container.decode(String.self, forKey: .fileName)

        let dmsDict = NSDictionary(contentsOfFile: CCMappings().dmsPath)
//        print("dms-reader-called")
        let fileDict = NSDictionary(contentsOfFile: "\(CCMappings.bundlesPath)\(fileName)/Info.plist")
        let bundleID = "\(fileDict?["CFBundleIdentifier"] ?? "com.what.unknown")"

        self.isDefaultModule = dmsDict?.allKeys.contains(where: { key in
            bundleID == "\(key)"
        }) == true
    }
}
