//
//  Customisations.swift
//  ControlConfig
//
//  Created by f1shy-dev on 09/02/2023.
//

import Foundation
import SwiftUI

// func overwriteModule(appBundleID: String, module: Module) -> Bool {
//    if module.bundleID == "com.apple.control-center.MagnifierModule" {
//        return plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCLaunchApplicationIdentifier", value: appBundleID)
//    }
//
//    let patch1 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCAssociatedBundleIdentifier", value: appBundleID)
//    let patch2 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "NSPrincipalClass", value: "CCUIAppLauncherModule")
//
//    return (patch1 && patch2)
// }

func applyIcons() -> Bool {
    var sMap: [Bool] = []
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

    let assetFolder = documentsURL.appendingPathComponent("AssetWorkspace")
    if !fileManager.fileExists(atPath: assetFolder.path) {
        return true
    }
    for module in fetchModules().filter({ module in
        !["ContinuousExposeModule.bundle", "ShazamModule.bundle", "DisplayModule.bundle"].contains(module.fileName)
    }) {
        let carFile = URL(fileURLWithPath: "\(CCMappings.bundlesPath)\(module.fileName)/Assets.car")
        let workspaceCarFile = assetFolder.appendingPathComponent("\(module.fileName)_Assets.car")

        if !fileManager.fileExists(atPath: carFile.path) || !fileManager.fileExists(atPath: workspaceCarFile.path) {
            continue
        }
        do {
            try MDC.overwriteFile(at: carFile.path, with: try Data(contentsOf: workspaceCarFile))
            print("icon Write - \(module.description)", write)
            sMap.append(true)
        } catch {
            print("icon Write FAILURE - \(module.description)")
            sMap.append(false)
        }
    }

    return !sMap.contains { $0 == false }
}

// MARK: - Get modules

func fetchModules() -> [Module] {
    do {
        #if targetEnvironment(simulator)
        return [Module(fileName: "FakeModule.module")]
        #else
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return [Module(fileName: "FakeModule.module")]
        }

        let files = try FileManager.default.contentsOfDirectory(atPath: CCMappings.bundlesPath)
        return files.map { file in
            Module(fileName: file)
        }
        #endif
    } catch {
        print(error)
        return []
    }
}



func applyChanges() -> (Bool, [String:Bool]) {
    let currentSet = AppState.shared.currentSet
    print() // emoji seperation
    var emptyDMS: [String: Any] = [:]
    var successMap: [String: Bool] = [:]
    let backupDMS = BackupManager.shared.latestBackup?.defaultModuleSettings
    
    var compressedAllowList: [String] = []
    for customisation in currentSet.list {
        let infoPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/Info.plist"
        let infoPlist = NSMutableDictionary()
//        let originalPlist = PlistHelpers.plistToDict(path: infoPath)
        guard let opc = BackupManager.shared.latestBackup?.modules[customisation.module.fileName]?.info_plist else {
            print("⛔️ Couldn't get original plist for \(customisation.module.description)")
            successMap["Module - \(customisation.module.description)"] = false
            continue
        }
        let originalPlist = NSMutableDictionary(dictionary: opc)
        let fileName = customisation.module.fileName
        let moduleBundleID = CCMappings.smallIDBasedModuleIDs[customisation.module.bundleID] as? String ?? customisation.module.bundleID
        var activeBundleID = customisation.module.bundleID
//        the "compressor"
        if CCMappings.fileNameBasedSmallIDs.allKeys.contains(where: { $0 as! String == fileName}) {
            print("⚙️ \(customisation.module.description) - Set small bundle ID")
            infoPlist.setValue(CCMappings.fileNameBasedSmallIDs[fileName], forKey: "CFBundleIdentifier")
            activeBundleID = CCMappings.fileNameBasedSmallIDs[fileName] as! String
            compressedAllowList.append(CCMappings.fileNameBasedSmallIDs[fileName] as! String)
            if let newName = CCMappings.moduleNames[fileName] as? String {
                infoPlist.setValue(newName, forKey: "CFBundleDisplayName")
                infoPlist.setValue(newName, forKey: "CFBundleName")
            }
        } else {
            compressedAllowList.append(moduleBundleID)
        }
        
        if CCMappings().hiddenModulesToPatch.contains(fileName) {
            print("⚙️ \(customisation.module.description) - Patch hidden module")
            if originalPlist.value(forKey: "SBIconVisibilityDefaultVisible") != nil {
                infoPlist.setValue(true, forKey: "SBIconVisibilityDefaultVisible")
            }
            
            if originalPlist.value(forKey: "SBIconVisibilitySetByAppPreference") != nil {
                infoPlist.setValue(false, forKey: "SBIconVisibilitySetByAppPreference")
            }

            
            if originalPlist.value(forKey: "SBIconVisibilityDefaultVisibleInstallTypes") != nil {
                infoPlist.setValue([], forKey: "SBIconVisibilityDefaultVisibleInstallTypes")
            }
            
            if let caps = originalPlist.value(forKey: "UIRequiredDeviceCapabilities") as? [String] {
                infoPlist.setValue(caps.filter {
                    !["DeviceSupportsActiveNFCReadingOnly"].contains($0)
                }, forKey: "UIRequiredDeviceCapabilities")
            }
        }
        
        switch customisation.mode {
        case .AppLauncher:
            infoPlist.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            if let appBundleID = customisation.launchAppBundleID {
                print("⚙️ \(customisation.module.description) - Patch appID \(appBundleID)")
                infoPlist.setValue(appBundleID, forKey: "CCLaunchApplicationIdentifier")
                infoPlist.setValue(appBundleID, forKey: "CCAssociatedBundleIdentifier")
            }
            if let appURLScheme = customisation.launchAppURLScheme {
                print("⚙️ \(customisation.module.description) - Patch url-scheme \(appURLScheme)")
                infoPlist.setValue(appURLScheme, forKey: "CCLaunchURL")
            }
        case .WorkflowLauncher:
            infoPlist.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            if let shortcutName = customisation.launchShortcutName {
                print("⚙️ \(customisation.module.description) - Patch shortcut \(shortcutName)")
                infoPlist.setValue("com.apple.shortcuts", forKey: "CCLaunchApplicationIdentifier")
                infoPlist.setValue("com.apple.shortcuts", forKey: "CCAssociatedBundleIdentifier")
                infoPlist.setValue("shortcuts://run-shortcut?name=" + shortcutName, forKey: "CCLaunchURL")
            }
        case .CustomAction:
            infoPlist.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            print("⚙️ \(customisation.module.description) - Patch custom action")
            infoPlist.setValue(Bundle.main.bundleIdentifier, forKey: "CCLaunchApplicationIdentifier")
            infoPlist.setValue(Bundle.main.bundleIdentifier, forKey: "CCAssociatedBundleIdentifier")
            switch customisation.customAction {
            case .Respring:
                infoPlist.setValue("controlconfig://respring", forKey: "CCLaunchURL")
            case .FrontboardRespring:
                if AppState.shared.debugMode { infoPlist.setValue("controlconfig://respring?type=frontboard", forKey: "CCLaunchURL") }
                else { infoPlist.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            case .BackboardRespring:
                if AppState.shared.debugMode { infoPlist.setValue("controlconfig://respring?type=backboard", forKey: "CCLaunchURL") }
                else { infoPlist.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            case .LegacyRespring:
                if AppState.shared.debugMode { infoPlist.setValue("controlconfig://respring?type=legacy", forKey: "CCLaunchURL") }
                else { infoPlist.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            }

        default:
//            print("default")
            let _ = ""
        }

//        let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/\(AppState.shared.sbRegionCode).lproj/InfoPlist.strings"
//        if FileManager.default.fileExists(atPath: stringsPath) {
//            print("File exists")
//        }

        // doesnt work ios15
//        if ["HomeControlCenterCompactModule.bundle", "HomeControlCenterModule.bundle"].contains(customisation.module.fileName), let newName = CCMappings.moduleNames[customisation.module.fileName] as? String {
//            infoPlist.setValue(newName, forKey: "CFBundleDisplayName")
//        }

        // PLIST PADDING ISSUE
//        if (customisation.hideAirplayText ?? false) == true || (customisation.hideFocusUIText ?? false) == true {
            if #available(iOS 16, *) {
                // code that should only run on iOS 16 or above
                if customisation.module.fileName == "FocusUIModule.bundle" {
                    let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/Localizable.loctable"
                    if let latestBkF = BackupManager.shared.latestBackup?.folderPath,
                       let backupCopy = PlistHelpers.plistToDict(path: latestBkF + "modules/\(customisation.module.fileName)/Localizable.loctable"),
                       
//                        let baseDict = NSMutableDictionary(contentsOfFile: stringsPath),
                        let baseKeys = backupCopy.allKeys as? [String]
                       
                    {
                        let new = NSMutableDictionary(dictionary: backupCopy)
                        
                        if customisation.hideFocusUIText == true {
                            for key in baseKeys.filter({$0 != "LocProvenance"}) {
                                if let sd = new.value(forKey: key) as? [String: String] {
                                    for key2 in sd.keys {
                                        new.setValue("", forKeyPath: "\(key).\(key2)")
                                    }
                                }
                                
                            }
                        }
                        
                        if let op = PlistHelpers.plistToDict(path: stringsPath) {
                            for i in CCMappings.removalPlistValues {
                                new.removeObject(forKey: i)
                                op.removeObject(forKey: i)
                            }
                            if new.isEqual(to:op as! [AnyHashable:Any]) {
                                if customisation.hideFocusUIText == true { print("⏩ Skipping hide Focus text - file same") }
                            } else {
                        if customisation.hideFocusUIText == true { print("⚙️ Focus - Hide text") }
                        else { print("⏮️ Reverting Focus - Hide text") }
                        successMap["Hide Focus Text (iOS 16)"] = PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: new), path: stringsPath)
                            }
                        }
                        
                    
                }
            } else {
                let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/\(AppState.shared.sbRegionCode).lproj/Localizable.strings"
                if FileManager.default.fileExists(atPath: stringsPath),
                   let latestBkF = BackupManager.shared.latestBackup?.folderPath,
                   let backupCopy = PlistHelpers.plistToDict(path: latestBkF + "modules/\(customisation.module.fileName)/\(AppState.shared.sbRegionCode).lproj/Localizable.strings") {
                    if customisation.module.fileName == "FocusUIModule.bundle"{
                        let new = customisation.hideFocusUIText == true ? NSMutableDictionary(dictionary: [
                            "MODULE_DEFAULT_TITLE": "",
                            "MODULE_ON_STATE": ""
                        ]): backupCopy
                        
                        if customisation.hideFocusUIText == true { print("⚙️ Focus - Hide text") }
                        else { print("⏮️ Reverting Focus - Hide text") }
                        successMap["Hide Focus Text (iOS 15)"] = (PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: new), path: stringsPath))
                    }
                    
                    if customisation.module.fileName == "AirPlayMirroringModule.bundle" {
                        var dict = NSMutableDictionary(dictionary: backupCopy)
                        if customisation.hideAirplayText == true {
                            dict.setValue("", forKey: "Screen Mirroring Compact")
                        }
//                        if let op = PlistHelpers.plistToDict(path: stringsPath) {
//                            for i in CCMappings.removalPlistValues {
//                                dict.removeObject(forKey: i)
//                                op.removeObject(forKey: i)
//                            }
//                            if dict.isEqual(to:op as! [AnyHashable:Any]) {
//                                if customisation.hideAirplayText == true { print("⏩ Skipping hide Screen Mirroring text - file same") }
//
//                            } else {
                                if customisation.hideAirplayText == true { print("⚙️ Screen Mirroring - Hide text") }
                                else { print("⏮️ Reverting Screen Mirroring - Hide text") }
                                successMap["Hide Screen Mirroring Text"] = PlistHelpers.writeDictToPlist(dict: dict, path: stringsPath)
//                            }
//                        }
                        
                        
                        
                    }
                }
                    //
                }
//            }
        }

        if let customName = customisation.customName, customName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            infoPlist.setValue(customName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "CFBundleDisplayName")
        }

        if customisation.disableOnHoldWidget == true {
            infoPlist.setValue(false, forKey: "CCSupportsApplicationShortcuts")
        }

        switch customisation.customSizeMode {
        case .Individual:
            let dict = [
                "portrait": [
                    "size": [
                        "width": customisation.customWidthPortrait ?? 1,
                        "height": customisation.customHeightPortrait ?? 1
                    ]
                ],
                "landscape": [
                    "size": [
                        "width": customisation.customWidthLandscape ?? 1,
                        "height": customisation.customHeightLandscape ?? 1
                    ]
                ]
            ]
            emptyDMS[activeBundleID] = dict
            print("⚙️ \(customisation.module.description) - Patch individual size")
            infoPlist.setValue(dict, forKey: "_CCModuleSizePROTOTYPE") // useless but whatevers
        case .BothWays:
            let dict = [
                "width": customisation.customWidthBothWays ?? 1,
                "height": customisation.customHeightBothWays ?? 1
            ]
            print("⚙️ \(customisation.module.description) - Patch bothway size")
            infoPlist.setValue(dict, forKey: "_CCModuleSizePROTOTYPE")
        case .None:
            // TODO: default size from backup
//            print("The size is NONE", customisation.module.bundleID)
//            let cbId = CCMappings.fileNameBasedSmallIDs[fileName] ?? customisation.module.bundleID
//            print("cbid", cbId)
            if let backupDMS = backupDMS, let backupSize = backupDMS[moduleBundleID] as? [String: Any] {
                print("⚙️ \(customisation.module.description) - Patch backup size")
                if let bothWaySize = backupSize["size"] as? [String: Any] {
                    infoPlist.setValue(bothWaySize, forKey: "_CCModuleSizePROTOTYPE")
                } else {
                    infoPlist.setValue(backupSize, forKey: "_CCModuleSizePROTOTYPE")
                    emptyDMS[activeBundleID] = backupSize
                }
                
//                emptyDMS[customisation.module.bundleID] = backupSize
            }
//            let dict = [
//                "width": 1,
//                "height": 1
//            ]
//            infoPlist.setValue(dict, forKey: "_CCModuleSizePROTOTYPE")
        }

//        if let ogP = originalPlist as? [AnyHashable: Any],  infoPlist.isEqual(to: ogP) == true {
//            print("Skipping \(customisation.module.description) - identical plist")
//        } else if let dict = infoPlist {
//            successMap["customInfo_\(customisation.module.description)"] = (PlistHelpers.writeDictToPlist(dict: dict, path: infoPath))
//        }
        
//        if infoPlist == [:] {
//            print("⏩ Skipping \(customisation.module.description) - no changes")
//        } else
        
        
            let dict = NSMutableDictionary(dictionary: originalPlist)
            for i in CCMappings.removalPlistValues {
                dict.removeObject(forKey: i)
                originalPlist.removeObject(forKey: i)
            }
            dict.addEntries(from: infoPlist as! [AnyHashable:Any])
//            if dict.isEqual(to:op as! [AnyHashable:Any]) {
//                print("⏩ Skipping \(customisation.module.description) - file same")
//            } else {
                successMap["Module - \(customisation.module.description)"] = (PlistHelpers.writeDictToPlist(dict: dict, path: infoPath))
//            }
        
    }

    
    if activeExploit == .KFD, let keys = CCMappings.fileNameBasedSmallIDs.allKeys as? [String] {
        let custom_modules = currentSet.list.map { $0.module.fileName }
        for fileName in keys.filter({ key in
            let fn = CCMappings.fileNameBasedSmallIDs[key] as? String
            let mapped = ["ios15", "ptrace", "mute"].map{fn?.contains($0)}
            if (!mapped.allSatisfy{$0 == false}) { return false }

            return !custom_modules.contains(key)            
        }) {
            print(fileName)
            //budget kfd compressor
            let module = Module(fileName: fileName)
            let infoPath = "\(CCMappings.bundlesPath)\(fileName)/Info.plist"
            if let infoPlist = PlistHelpers.plistToDict(path: infoPath), let smallID = CCMappings.fileNameBasedSmallIDs[fileName] as? String {
                
                
                print("⚙️ \(module.description) - Set small bundle ID @kfd")
                infoPlist.setValue(smallID, forKey: "CFBundleIdentifier")
                compressedAllowList.append(smallID)
                if let newName = CCMappings.moduleNames[fileName] as? String {
                    infoPlist.setValue(newName, forKey: "CFBundleDisplayName")
                    infoPlist.setValue(newName, forKey: "CFBundleName")
                }
                
                
                let decompressedID = CCMappings.smallIDBasedModuleIDs[module.bundleID] as? String ?? module.bundleID
                if let backupDMS = backupDMS, let backupSize = backupDMS[decompressedID] as? [String: Any] {
                
                    if let bothWaySize = backupSize["size"] as? [String: Any] {
                        print("⚙️ \(module.description) - Patch backup size +bothway @kfd", bothWaySize)
                        infoPlist.setValue(bothWaySize, forKey: "_CCModuleSizePROTOTYPE")
                    } else {
                        print("⚙️ \(module.description) - Patch backup size +individual @kfd")
                        infoPlist.setValue(backupSize, forKey: "_CCModuleSizePROTOTYPE")
                        emptyDMS[smallID] = backupSize
                    }
                    
    //                emptyDMS[customisation.module.bundleID] = backupSize
                }
                successMap["KModule - \(module.description)"] = (PlistHelpers.writeDictToPlist(dict: infoPlist, path: infoPath))

            } else {
                successMap["KModule - \(module.description)"] = false

            }
        }
    }
    
    
//    revert modules
    
    let notAddedModules = fetchModules().filter { mod in
        !currentSet.list.contains(where: {$0.module.fileName == mod.fileName})
    }.filter{mod in
        CCMappings().hiddenModulesToPatch.contains(mod.fileName)
    }
    
    for module in notAddedModules {
        let infoPath = "\(CCMappings.bundlesPath)\(module.fileName)/Info.plist"
        if let infoPlist = PlistHelpers.plistToDict(path: infoPath),
            let moduleBackupPath = BackupManager.shared.latestBackup?.modules[module.fileName]?.info_path,
            let backupPlist = PlistHelpers.plistToDict(path: moduleBackupPath){
            var shouldRevert = false
            
            if let og = backupPlist.value(forKey: "SBIconVisibilitySetByAppPreference") as? Bool, let new = infoPlist.value(forKey: "SBIconVisibilitySetByAppPreference") as? Bool, og != new {
//                print("sbivsbap")
                shouldRevert = true
            }
            
            if let og = backupPlist.value(forKey: "SBIconVisibilityDefaultVisible") as? Bool, let new = infoPlist.value(forKey: "SBIconVisibilityDefaultVisible") as? Bool, og != new {
//                print("sbivdv")
                shouldRevert = true
            }
            
            if let og = backupPlist.value(forKey: "UIDeviceFamily") as? [Int], let new = infoPlist.value(forKey: "SBIconVisibilitySetByAppPreference") as? [Int], og != new {
//                print("uidf")
                shouldRevert = true
            }
            
            if let og = backupPlist.value(forKey: "UIRequiredDeviceCapabilities") as? [String], let new = infoPlist.value(forKey: "UIRequiredDeviceCapabilities") as? [String], og != new {
//                print("uirdc")
                shouldRevert = true
            }
            
            if let og = backupPlist.value(forKey: "SBIconVisibilityDefaultVisibleInstallTypes") as? [String], let new = infoPlist.value(forKey: "SBIconVisibilityDefaultVisibleInstallTypes") as? [String], og != new {
//                print("sbvdvit")
                shouldRevert = true
            }
            
            if shouldRevert {
                print("⏮️ Reverting hidden module - \(module.description)")
                successMap["Revert Hidden - \(module.fileName)"] = PlistHelpers.writeDictToPlist(dict: backupPlist, path: infoPath)
            }
        } else {
            successMap["Revert Hidden - \(module.fileName)"] = false
            print("⛔️ Couldn't locate hidden module \(module.fileName) in backup to check revert...")
        }
    }


    let dmsPath = CCMappings().dmsPath
    print("⚙️ Writing DMS (sizes file)")
    successMap["DMS (Module Sizings)"] = PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: emptyDMS), path: dmsPath)

    
    
    if currentSet.enableCustomColors == true {
        print("⚙️ Writing colour recipes")
        if let c = currentSet.moduleColor, let b = currentSet.moduleBlur {
            successMap["Colours - Module"] = (ColorTools.applyMaterialRecipe(filePath: CCMappings.moduleMaterialRecipePath, color: c, blur: b, includeSpecificsForCCModules: true))
        }
        
        if let cB = currentSet.moduleBGColor, let bB = currentSet.moduleBGBlur {
            successMap["Colours - Module Background"] = (ColorTools.applyMaterialRecipe(filePath: CCMappings.moduleBackgroundMaterialRecipePath, color: cB, blur: bB, includeSpecificsForCCModules: false))
        }
    }
    
        if activeExploit == .MDC {
//            guard let moduleConf = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath) else { throw GenericError.runtimeError("no moduleconf readed") }
            let moduleConf = NSMutableDictionary()
            moduleConf["disabled-module-identifiers"] = []
            moduleConf["userenabled-fixed-module-identifiers"] = []
            moduleConf["module-identifiers"] = currentSet.list.filter {!$0.module.fileName.contains("ConferenceControlCenterModule")}.map {
                CCMappings.fileNameBasedSmallIDs[$0.module.fileName] as? String ?? $0.module.bundleID  } as [String]
            moduleConf["version"] = 1

            print("⚙️ Writing moduleconf (order)")
            successMap["ModuleConf (Enabled Modules)"] = PlistHelpers.writeDictToPlist(dict: moduleConf, path: CCMappings.moduleConfigurationPath)
        }
        
        do {
            if activeExploit == .KFD {
                for module in fetchModules() {
                    let comp = CCMappings.fileNameBasedSmallIDs[module.fileName] as? String ?? module.bundleID
                    if !compressedAllowList.contains(comp) {
                        compressedAllowList.append(comp)
                    }
                }
            }
            print(compressedAllowList)
            let filteredNew = compressedAllowList.filter { $0 != String(repeating: "*", count: $0.count) }
            let newData = try! PropertyListSerialization.data(fromPropertyList: filteredNew, format: .binary, options: 0)
            guard let padData = PlistHelpers.arrayPlistPadding(Plist_Data: newData, Default_URL_STR: CCMappings.moduleAllowedListPath) else { throw GenericError.runtimeError("list unable to be padded") }
            print("⚙️ Writing module allow-list")
            try MDC.overwriteFile(at: CCMappings.moduleAllowedListPath, with: padData)
            successMap["Module Allowed List (CC Order)"] = true
        }
        catch {
            print(error)
            successMap["Module Allowed List (CC Order)"] = false
        }

    
    print(successMap)
    if successMap.allSatisfy({$1 == true}) {
        if successMap.count == 0 {
            print("✅ Completed successfully (nothing changed on disk)")
        } else {
            print("✅ Completed \(successMap.count) operations successfully")
        }
    } else {
        let failed = successMap.filter { $0.value == false }.map { $0.key }.joined(separator: ", ")
        print("⛔️ Not all operations succeeded")
        print("    ⏺️ \(successMap.filter {$0.value == true}.count)/\(successMap.count) operations succeeded")
        print("    ⏺️ \(failed) failed")
//        do {
//            let data = try JSONSerialization.data(withJSONObject: successMap, options: .prettyPrinted)
//            if let prettyPrintedString = String(data: data, encoding: .utf8) {
//                print(prettyPrintedString)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    print() // emoji seperation
//    print("successmap", successMap)
    return (!successMap.values.contains { $0 == false },successMap)
}
