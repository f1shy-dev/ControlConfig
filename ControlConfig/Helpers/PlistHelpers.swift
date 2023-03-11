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
        print("pd.count", Plist_Data.count, "dd.count", Default_Data.count)
        guard let Plist = try? PropertyListSerialization.propertyList(from: Plist_Data, format: nil) as? [String: Any] else { return nil }
        var EditedDict = Plist
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0) else { return nil }
        var count = 0
        print("DefaultData - " + String(Default_Data.count))
        while true {
            newData = try! PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0)
            if newData.count >= Default_Data.count { break }
            count += 1
            EditedDict.updateValue(String(repeating: "*", count: Int(floor(Double(count/2)))), forKey: "0")
            EditedDict.updateValue(String(repeating: "+", count: count - Int(floor(Double(count/2)))), forKey: "MdC")
        }
        print("ImportData - " + String(newData.count))
        return newData
    }

    public static func arrayPlistPadding(Plist_Data: Data, Default_URL_STR: String) -> Data? {
        guard let Default_Data = try? Data(contentsOf: URL(fileURLWithPath: Default_URL_STR)) else { return nil }
        if Plist_Data.count == Default_Data.count { return Plist_Data }
        print("pd.count", Plist_Data.count, "dd.count", Default_Data.count)
        guard let Plist = try? PropertyListSerialization.propertyList(from: Plist_Data, format: nil) as? [String] else { return nil }
        var EditedDict = Plist
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0) else { return nil }
        EditedDict = EditedDict.filter { $0 != String(repeating: "*", count: $0.count) }
//        print("FILTER")
        var count = 0
        print("DefaultData - " + String(Default_Data.count))
        while true {
            newData = try! PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0)
            if newData.count >= Default_Data.count { break }
            count += 1
            EditedDict = EditedDict.filter { $0 != String(repeating: "*", count: $0.count) }
            EditedDict.append(String(repeating: "*", count: count))
        }
        print("ImportData - " + String(newData.count))
        return newData
    }

    static func addEmptyData(matchingSize: Int, to plist: [String: Any]) throws -> Data {
        var newPlist = plist
        // create the new data
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { throw "Unable to get data" }
        // add data if too small
        // while loop to make data match because recursive function didn't work
        // very slow, will hopefully improve
        var newDataSize = newData.count
        var added = matchingSize - newDataSize
        if added < 0 {
            added = 1
        }
        var count = 0
        while newDataSize != matchingSize || count < 200 {
            count += 1
            if added < 0 {
                break
            }
            newPlist.updateValue(String(repeating: "#", count: added), forKey: "MdC")
            do {
                newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
            } catch {
                newDataSize = -1
                break
            }
            newDataSize = newData.count
            if count < 5 {
                // max out this method at 5 if it isn't working
                added += matchingSize - newDataSize
            } else {
                if newDataSize > matchingSize {
                    added -= 1
                } else if newDataSize < matchingSize {
                    added += 1
                }
            }
        }

        return newData
    }

    public static func betterPlistPadding(replacementData: Data, filePath: String) -> Data? {
        guard let currentData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return nil }
        if replacementData.count == currentData.count { return replacementData }

//        print("padding replacement \(replacementData.count) to current \(currentData.count)")
        guard let replacementPlist = try? PropertyListSerialization.propertyList(from: replacementData, format: nil) as? [String: Any] else { return nil }
        guard var withEmpty = try? PlistHelpers.addEmptyData(matchingSize: currentData.count, to: replacementPlist) else { return nil }
        return withEmpty
    }

    public static func writeDictToPlist(dict: NSMutableDictionary, path: String) -> Bool {
        dict.removeObjects(forKeys: CCMappings.removalPlistValues)
        let newData = try! PropertyListSerialization.data(fromPropertyList: dict as! [String: Any], format: .binary, options: 0)
//        print(dict, newData.count)
//        let padData = plistPadding(Plist_Data: newData, Default_URL_STR: path)! as Data
        guard let padData = betterPlistPadding(replacementData: newData, filePath: path) else { return false }
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
