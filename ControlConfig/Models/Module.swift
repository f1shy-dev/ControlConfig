//
//  Module.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Foundation

class Module: Identifiable, CustomStringConvertible, Codable, ObservableObject, Equatable,Hashable {
    var id: String { fileName }
    var fileName: String

//    var isDefaultModule: Bool

    static func ==(lhs: Module, rhs: Module) -> Bool {
        return lhs.fileName == rhs.fileName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
    }

    init(fileName: String) {
        self.fileName = fileName
    }
    
    init?(bundleID: String) {
        self.fileName = ""
        if let newFl = CCMappings.smallIDBasedFileNames[bundleID] as? String{
            self.fileName = newFl
        } else {
            do {
                
                let contents = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: CCMappings.bundlesPath), includingPropertiesForKeys: nil, options: [])
                for folder in contents where folder.hasDirectoryPath {
                    let infoPlistUrl = folder.appendingPathComponent("Info.plist")
                    if let infoPlistData = try? Data(contentsOf: infoPlistUrl),
                       let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any],
                       let bundleIdInPlist = plist["CFBundleIdentifier"] as? String,
                       bundleIdInPlist == bundleID {
                        self.fileName = folder.lastPathComponent
                        
                    }
                }
            } catch {
                print("Error while trying to find bundleid \(bundleID)")
                return nil
            }
        }
    }

    var sfIcon: String {
        if let icon = CCMappings().moduleSFIcons[fileName] {
            return "\(icon)"
        }
        return "app.dashed"
    }

    var bundleID: String {
        if let fileDict = BackupManager.shared.latestBackup?.modules[fileName]?.info_plist {
            return "\(fileDict["CFBundleIdentifier"] ?? "com.what.unknown")"
        } else {
            return "com.what.unknown"
        }
    }

    var sizesInDMSFile: [String] {
        let dmsDict = PlistHelpers.plistToDict(path: CCMappings().dmsPath)
        if dmsDict?.allKeys.contains(where: { key in
            bundleID == "\(key)"
        }) == true {
            if let module = dmsDict?[bundleID] {
//                print(module)
                return PlistHelpers.getKeys(from: module as! [String: Any])
            }
        }
        return []
    }

    var description: String {
        if let setName = CCMappings.moduleNames[fileName] {
            return "\(setName)"
        }
        if let fileDict = BackupManager.shared.latestBackup?.modules[fileName]?.info_plist {
            let name = "\(fileDict["CFBundleDisplayName"] ?? fileDict["CFBundleName"] ?? "Unknown - \(self.fileName)")"
            print(name, fileName + "%%")
            return name.components(separatedBy: "Module").first ?? name
        }
        return "Unknown - \(self.fileName)"
    }

    enum CodingKeys: String, CodingKey {
        case fileName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileName = try container.decode(String.self, forKey: .fileName)
    }
}
