//
//  PlistHelpers.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//  Credits: straight_tamago
//

import Foundation

public enum DictPaddingMethods {
    case Cowabunga, ByteHackery, Tamago, None
}

public enum PlistHelpers {
    public static func plistPadding(Plist_Data: Data, Default_URL_STR: String) -> Data? {
        print("s1")
        guard let Default_Data = try? Data(contentsOf: URL(fileURLWithPath: Default_URL_STR)) else { return nil }
        print("s2")
        if Plist_Data.count == Default_Data.count { return Plist_Data }
        print("s3")
        guard let Plist = try? PropertyListSerialization.propertyList(from: Plist_Data, format: nil) as? [String: Any] else { return nil }
        var EditedDict = Plist
        print("s4")
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0) else { return nil }
        print("s5")
        var count = 0
//        print("DefaultData - " + String(Default_Data.count))
        while true {
            newData = try! PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0)
            if newData.count >= Default_Data.count { break }
            count += 1
            EditedDict.updateValue(String(repeating: "*", count: Int(floor(Double(count/2)))), forKey: "0")
            EditedDict.updateValue(String(repeating: "+", count: count - Int(floor(Double(count/2)))), forKey: "MdC")
        }
//        print("ImportData - " + String(newData.count))
        return newData
    }

    public static func arrayPlistPadding(Plist_Data: Data, Default_URL_STR: String) -> Data? {
        guard let Default_Data = try? Data(contentsOf: URL(fileURLWithPath: Default_URL_STR)) else { return nil }
        if Plist_Data.count == Default_Data.count { return Plist_Data }
//        print("pd.count", Plist_Data.count, "dd.count", Default_Data.count)
        guard let Plist = try? PropertyListSerialization.propertyList(from: Plist_Data, format: nil) as? [String] else { return nil }
        var EditedDict = Plist
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0) else { return nil }
        EditedDict = EditedDict.filter { $0 != String(repeating: "*", count: $0.count) }
//        print("FILTER")
        var count = 0
//        print("DefaultData - " + String(Default_Data.count))
        while true {
            newData = try! PropertyListSerialization.data(fromPropertyList: EditedDict, format: .binary, options: 0)
            if newData.count >= Default_Data.count { break }
            count += 1
            EditedDict = EditedDict.filter { $0 != String(repeating: "*", count: $0.count) }
            EditedDict.append(String(repeating: "*", count: count))
        }
//        print("ImportData - " + String(newData.count))
        return newData
    }

    static func addEmptyData(matchingSize: Int, to plist: [String: Any]) throws -> Data {
        var newPlist = plist
        guard var newData = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { throw "Unable to get data" }
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

//    public static func padDataWithPaddingBytes(_ data: Data, numPaddingBytes: Int) -> Data? {
//        do {
//            let trailerData = Array(data.suffix(32))
//            let offsetTableOffsetSize = trailerData[6]
//            let objectRefSize = trailerData[7]
//            let numObjects = trailerData[8 ..< 16].withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
//            let offsetTableOffset = trailerData[24 ..< 32].withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
//            let paddingPos = Int(offsetTableOffset + (numObjects * UInt64(offsetTableOffsetSize)))
//            print("paddingpos \(paddingPos)")
//            print("npb \(numPaddingBytes)")
//            //    let paddingBytes = data[paddingPos ..< data.count - 32].count
//
//            var padData = data[0 ..< paddingPos] + Data(repeating: 0xAA, count: numPaddingBytes) + data[(data.count - 32)...]
//
//            return padData
//        } catch {
//            return nil
//        }
//    }
    
    public static func dictionaryPadding(dict:NSMutableDictionary, path:String, method: DictPaddingMethods = .Cowabunga) -> Data? {
        let replacementData = try! PropertyListSerialization.data(fromPropertyList: dict as! [String: Any], format: .binary, options: 0)
        if method == .None { return replacementData }
        guard let currentData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        if replacementData.count == currentData.count { return replacementData }
        if replacementData.count > currentData.count { return nil }

        switch method {
        case .Cowabunga:
            guard let replacementPlist = try? PropertyListSerialization.propertyList(from: replacementData, format: nil) as? [String: Any] else { return nil }
            return try? PlistHelpers.addEmptyData(matchingSize: currentData.count, to: replacementPlist)
        case .ByteHackery:
            return insaneNewPaddingMethodUsingBytes(replacementData, padToBytes: currentData.count)
        case .Tamago:
            return plistPadding(Plist_Data: replacementData, Default_URL_STR: path)
        case .None:
            return replacementData
        }
    }
    
    public static func dictionaryPadding(dict:[AnyHashable:Any], path:String, method: DictPaddingMethods = .Cowabunga) -> Data? {
        return self.dictionaryPadding(dict: NSMutableDictionary(dictionary: dict), path: path, method: method)
    }
    

    public static func writeDictToPlist(dict: NSMutableDictionary, path: String, method: DictPaddingMethods = .Cowabunga) -> Bool {
        dict.removeObjects(forKeys: CCMappings.removalPlistValues)
        guard let padData = self.dictionaryPadding(dict: dict, path: path, method: method) else { return false }
        do {
            try MDC.overwriteFile(at: path, with: padData)
            return true
        } catch {
            print("Failed to write", error)
            return false
        }
    }

    public static func plistToDict(path: String) -> NSMutableDictionary? {
        if activeExploit == .KFD && path.contains("/var/mobile/Library/ControlCenter") {
            if kfd == 0 {return nil}
            let cPathtoTargetFile = path.withCString { ptr in
                return strdup(ptr)
            }

            let fileData = funVnodeRead(cPathtoTargetFile)
            if let fileData = fileData {
                let data = Data(bytes: fileData, count: Int(strlen(fileData)))
                return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? NSMutableDictionary
            } else {
                return nil
            }
        }
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
