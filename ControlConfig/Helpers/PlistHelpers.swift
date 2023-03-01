//
//  PlistHelpers.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//  Credits: straight_tamago
//

import Foundation

public enum PlistHelpers {
    public static func plistPadding(Plist_Data: Data, Default_URL_STR: String) -> Data? {
        guard let Default_Data = try? Data(contentsOf: URL(fileURLWithPath: Default_URL_STR)) else { return nil }
        if Plist_Data.count == Default_Data.count { return Plist_Data }
        guard let Plist = try? PropertyListSerialization.propertyList(from: Plist_Data, format: nil) as? [String: Any] else { return nil }
        var EditedDict = Plist
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0) else { return nil }
        var count = 0
        print("DefaultData - " + String(Default_Data.count))
        while true {
            newData = try! PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0)
            if newData.count >= Default_Data.count { break }
            count += 1
            EditedDict.updateValue(String(repeating: "0", count: count), forKey: "0")
        }
        print("ImportData - " + String(newData.count))
        return newData
    }

    public static func writeDictToPlist(dict: NSMutableDictionary, path: String) -> Bool {
        dict.removeObjects(forKeys: [
            "DTPlatformBuild",
            "DTSDKBuild",
            "DTXcodeBuild",
            "DTCompiler",
            "DTSDKName",
            "DTXcode",
            "BuildMachineOSBuild",
            "0"
        ])
        let newData = try! PropertyListSerialization.data(fromPropertyList: dict as! [String: Any], format: .binary, options: 0)
        let padData = plistPadding(Plist_Data: newData, Default_URL_STR: path)! as Data
        // newData = newPlist
        return MDC.overwriteFile(at: path, with: padData)
    }

    public static func plistToDict(path: String) -> NSMutableDictionary? {
        return NSMutableDictionary(contentsOfFile: path)
    }

    // <3 chatgpt
    public static func getKeys(from dictionary: [String: Any], prefix: String = "") -> [String] {
        var keys: [String] = []
        for (key, value) in dictionary {
            let newPrefix = prefix.isEmpty ? key : "\(prefix).\(key)"
            if let subDict = value as? [String: Any] {
                keys += getKeys(from: subDict, prefix: newPrefix)
            } else {
                keys.append(newPrefix)
            }
        }
        return keys
    }

    public static func plistBytesSize(_ dictionary: NSMutableDictionary) -> Int {
        let newData = try! PropertyListSerialization.data(fromPropertyList: dictionary as! [String: Any], format: .binary, options: 0)
        return newData.count
    }

    public static func filePathBytesSize(_ filepath: String) -> Int? {
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfItem(atPath: filepath) else {
            return nil
        }
        guard let size = attributes[FileAttributeKey.size] as? Int else {
            return nil
        }
        return size
    }
}
