//
//  Common.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import Foundation
import SwiftUI

// MARK: - MagnifierModule

let bundlesPath = "/System/Library/ControlCenter/Bundles/"
// TODO: More CC Modules!
let bundleBasedModuleNameOverrides: NSDictionary = [
    "com.apple.shazamkit.controlcenter.ShazamModule": "Shazam",
    "com.apple.control-center.DisplayModule": "Brightness"
    // TODO: meadiacontrolsaudio, silencecallsccwidget and others
]

struct CCModule: Hashable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    var fileName: String
    var bundleID: String {
        let fileDict = NSDictionary(contentsOfFile: "\(bundlesPath)\(fileName)/Info.plist")
        return "\(fileDict?["CFBundleIdentifier"] ?? "com.what.unknown")"
    }

    var description: String {
        let fileDict = NSDictionary(contentsOfFile: "\(bundlesPath)\(fileName)/Info.plist")

        if let setName = bundleBasedModuleNameOverrides[bundleID] {
            return "\(setName)"
        }

        let name = "\(fileDict?["CFBundleDisplayName"] ?? fileDict?["CFBundleName"] ?? "Unknown Module")"
        return name.components(separatedBy: "Module").first ?? name
    }

    enum CodingKeys: String, CodingKey {
        case fileName
    }
}

struct CCCustomisation: Codable {
    var isEnabled: Bool
    var module: CCModule
    var launchAppBundleID: String?
    var customWidth: Int?
    var customHeight: Int?
    var description: String {
        var str: [String] = []
        if let app = launchAppBundleID {
            str.append("Opens \(app)")
        }

        if (customWidth != nil) || (customHeight != nil) {
            str.append("Custom W/H")
        }

        if str.count > 0 {
            return str.joined(separator: ",")
        }

        return "Doesn't do anything..."
    }

//    var customIcon: SomeIconTypeIdk?

    enum CodingKeys: String, CodingKey {
        case isEnabled
        case module
        case launchAppBundleID
        case customWidth
        case customHeight
    }
}

func overwriteModule(appBundleID: String, module: CCModule) -> Bool {
    if module.bundleID == "com.apple.control-center.MagnifierModule" {
        return plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCLaunchApplicationIdentifier", value: appBundleID)
    }

    let patch1 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCAssociatedBundleIdentifier", value: appBundleID)
    let patch2 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "NSPrincipalClass", value: "CCUIAppLauncherModule")

    return (patch1 && patch2)
}

func getCCModules() -> [CCModule] {
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: "/System/Library/ControlCenter/Bundles/")
        return files.map { file in
            CCModule(fileName: file)
        }
    } catch {
        print(error)
        return []
    }
}

// credit straight_tamago
func PlistPadding(Plist_Data: Data, Default_URL_STR: String) -> Data? {
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

// MARK: - Plist editor

func plistChangeStr(plistPath: String, key: String, value: String) -> Bool {
    let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))

    let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
    func changeValue(_ dict: [String: Any], _ key: String, _ value: String) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = value
            } else if let subDict = v as? [String: Any] {
                newDict[k] = changeValue(subDict, key, value)
            }
        }
        return newDict
    }
    var newPlist = plist
    newPlist = changeValue(newPlist, key, value)
    func cleanPlist(_ dict: [String: Any]) -> [String: Any] {
        var newDict = dict
        newDict.removeValue(forKey: "DTPlatformBuild")
        newDict.removeValue(forKey: "DTSDKBuild")
        newDict.removeValue(forKey: "DTXcodeBuild")
        newDict.removeValue(forKey: "DTCompiler")
        newDict.removeValue(forKey: "DTSDKName")
        return newDict
    }
    newPlist = cleanPlist(newPlist)
    print(newPlist)
    let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
    let padData = PlistPadding(Plist_Data: newData, Default_URL_STR: plistPath)! as Data
    // newData = newPlist
    return overwriteFileWithDataImpl(originPath: plistPath, replacementData: padData)
}

// MARK: - Overwrite file function

func overwriteFileWithDataImpl(originPath: String, replacementData: Data) -> Bool {
    #if false
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path

        let pathToRealTarget = originPath
        let originPath = documentDirectory + originPath
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
        try! origData.write(to: URL(fileURLWithPath: originPath))
    #endif

    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("Original file: \(originalFileSize)")
        print("Replacement file: \(replacementData.count)")
        print("File too big!")
        return false
    }
    lseek(fd, 0, SEEK_SET)

    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        return true
    }

    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count
                )
            }
            if overwriteSucceeded {
                overwroteOne = true
                print("Successfully overwrote!")
                break
            }
            print("try again?!")
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            return false
        }
    }
    print(Date())
    print("Successfully overwrote!")
    return true
}

func xpc_crash(_ serviceName: String) {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: serviceName.utf8.count)
    defer { buffer.deallocate() }
    strcpy(buffer, serviceName)
    xpc_crasher(buffer)
}

func respring() {
    let processes = [
        // only kill frontboard since killing backboard doesnt apply cc tweaks??
        "com.apple.cfprefsd.daemon",
//        "com.apple.backboard.TouchDeliveryPolicyServer",
        "com.apple.frontboard.systemappservices"
    ]
    for process in processes {
        xpc_crash(process)
    }
}
