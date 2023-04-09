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

func compressBundleIDs_old() -> Bool {
    var success: [Bool] = []

    let modules = fetchModules()
    modules.prefix(9).forEach { module in
        let path = "\(CCMappings.bundlesPath)\(module.fileName)/Info.plist"
        guard let currentData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return success.append(false) }

        guard var currentPlist = try? PropertyListSerialization.propertyList(from: currentData, format: nil) as? [String: Any] else { return success.append(false) }
        let cs = module.fileName.checksum()
        print("patching \(module) to \(cs)")
        currentPlist["CFBundleIdentifier"] = cs

        currentPlist.removeValue(forKey: "0")
        currentPlist.removeValue(forKey: "MdC")

        let newData = try! PropertyListSerialization.data(fromPropertyList: currentPlist, format: .xml, options: 0)
//        print(dict, newData.count)
//        let padData = plistPadding(Plist_Data: newData, Default_URL_STR: path)! as Data
        guard let padData = PlistHelpers.betterPlistPadding(replacementData: newData, filePath: path) else { return success.append(false) }
        // newData = newPlist
        success.append(MDC.overwriteFile(at: path, with: padData))
        usleep(100000)
    }

    print("successmap-compresser", success)
    return !success.contains { $0 == false }
}

func betterBundleIDCompressor() -> (success: Bool, ogNew: [String: String]) {
    let bundlesPath = CCMappings.bundlesPath
    var success: [Bool] = []
    var ogNew: [String: String] = [:]

    do {
        let bundleFolders = try FileManager.default.contentsOfDirectory(atPath: bundlesPath)
        for folder in bundleFolders.filter({ folder in
            CCMappings.fileNameBasedSmallIDs.allKeys.contains { $0 as! String == folder }
        }) {
            let plistPath = "\(bundlesPath)/\(folder)/Info.plist"

            guard let plistData = FileManager.default.contents(atPath: plistPath),
                  var plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]
            else { success.append(false); continue }

            guard let ogID = plist["CFBundleIdentifier"] as? String else { success.append(false); continue }
            guard let cs = CCMappings.fileNameBasedSmallIDs[folder] as? String else { success.append(false); continue }
            ogNew[ogID] = cs
            plist["CFBundleIdentifier"] = cs
            for i in CCMappings.removalPlistValues {
                plist.removeValue(forKey: i)
            }
            if let newName = CCMappings.moduleNames[folder] as? String {
                plist["CFBundleDisplayName"] = newName
                plist["CFBundleName"] = newName
            }

            let plistDataNew = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
            success.append(PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: plist), path: plistPath))

//            if let newPad = PlistHelpers.plistPadding(Plist_Data: plistDataNew, Default_URL_STR: plistPath) {
//                success.append(MDC.overwriteFile(at: plistPath, with: newPad))
//                print("MDC patched \(folder) og\(plistData.count) new\(newPad.count)")
//            } else { success.append(false); continue }
        }
    } catch {
        success.append(false)
        fatalError("Error getting list of subfolders in bundles folder: \(error.localizedDescription)")
    }

    do {
        guard let moduleConf = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath) else { throw GenericError.runtimeError(":(") }
        moduleConf["disabled-module-identifiers"] = []
        moduleConf["userenabled-fixed-module-identifiers"] = []
        success.append(PlistHelpers.writeDictToPlist(dict: moduleConf, path: CCMappings.moduleConfigurationPath))

        guard var allowedList = NSArray(contentsOfFile: CCMappings.moduleAllowedListPath) as? [String] else { throw GenericError.runtimeError(":(") }

        allowedList = allowedList.map { ogNew[$0] ?? $0 }
        if !allowedList.contains("focusui") { allowedList.append("focusui") }
        print("OGNEW", ogNew)
        print("ALLOWNEW", allowedList)
        let newData = try! PropertyListSerialization.data(fromPropertyList: allowedList, format: .binary, options: 0)
//        guard let padData = PlistHelpers.arrayPlistPadding(Plist_Data: newData, Default_URL_STR: CCMappings.moduleAllowedListPath) else { throw GenericError.runtimeError(":(") }
        guard let currentData = try? Data(contentsOf: URL(fileURLWithPath: CCMappings.moduleAllowedListPath)) else { throw GenericError.runtimeError(":(") }

        guard let padData = try? insaneNewPaddingMethodUsingBytes(newData, padToBytes: currentData.count) else { throw GenericError.runtimeError(":(") }
        success.append(MDC.overwriteFile(at: CCMappings.moduleAllowedListPath, with: padData))
    } catch {
        success.append(false)
    }
    return (!success.contains { $0 == false }, ogNew)
}

func patchHiddenModules() -> Bool {
    let bundlesPath = CCMappings.bundlesPath
    var success: [Bool] = []

    do {
        let bundleFolders = try FileManager.default.contentsOfDirectory(atPath: bundlesPath)
        for folder in bundleFolders.filter({ folder in
            CCMappings.hiddenModulesToPatch.contains { $0 == folder }
        }) {
            let plistPath = "\(bundlesPath)/\(folder)/Info.plist"

            guard let plistData = FileManager.default.contents(atPath: plistPath),
                  var plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]
            else { success.append(false); continue }

            for i in CCMappings.removalPlistValues {
                plist.removeValue(forKey: i)
            }

            if plist["SBIconVisibilityDefaultVisible"] != nil {
                plist["SBIconVisibilityDefaultVisible"] = true
            }

            if plist["SBIconVisibilitySetByAppPreference"] != nil {
                plist["SBIconVisibilitySetByAppPreference"] = false
            }

            if plist["SBIconVisibilityDefaultVisibleInstallTypes"] != nil {
                plist["SBIconVisibilityDefaultVisibleInstallTypes"] = []
            }

            if let caps = plist["UIRequiredDeviceCapabilities"] as? [String] {
                plist["UIRequiredDeviceCapabilities"] = caps.filter {
                    !["DeviceSupportsActiveNFCReadingOnly"].contains($0)
                }
            }

            plist["UIDeviceFamily"] = [1, 2]

            let plistDataNew = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)

            success.append(PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: plist), path: plistPath))
            //            if let newPad = PlistHelpers.plistPadding(Plist_Data: plistDataNew, Default_URL_STR: plistPath) {
//                success.append(MDC.overwriteFile(at: plistPath, with: newPad))
//                print("MDC patched \(folder) og\(plistData.count) new\(newPad.count)")
//            } else { success.append(false); continue }
        }
    } catch {
        success.append(false)
        fatalError("Error getting list of subfolders in bundles folder: \(error.localizedDescription)")
    }

    return !success.contains { $0 == false }
}

func applyChanges(customisations: CustomisationList) -> Bool {
    let dmsPlistOriginal = PlistHelpers.plistToDict(path: CCMappings().dmsPath)
//    var dmsPlist = PlistHelpers.plistToDict(path: CCMappings().dmsPath)
    var emptyDMS: [String: Any] = [:]

//    var success: [Bool] = []
    var successMap: [String: Bool] = [:]

    let compressResult = betterBundleIDCompressor()
    let ogNew = compressResult.ogNew
    var newOg = [String: String]()
    for (key, value) in ogNew {
        newOg[value] = key
    }

//    success.append(compressResult.success)
    successMap["compressor"] = compressResult.success
    successMap["patchHidden"] = patchHiddenModules()

    for customisation in customisations.list.filter({ c in
        c.isEnabled
    }) {
        let infoPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/Info.plist"
        let infoPlist = PlistHelpers.plistToDict(path: infoPath)
        switch customisation.mode {
        case .AppLauncher:
            infoPlist?.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            if let appBundleID = customisation.launchAppBundleID {
                print("patching \(customisation.module.description) to \(appBundleID)")
                infoPlist?.setValue(appBundleID, forKey: "CCLaunchApplicationIdentifier")
                infoPlist?.setValue(appBundleID, forKey: "CCAssociatedBundleIdentifier")
            }
            if let appURLScheme = customisation.launchAppURLScheme {
                print("patching \(customisation.module.description) to app-url-scheme \(appURLScheme)")
                infoPlist?.setValue(appURLScheme, forKey: "CCLaunchURL")
            }
        case .WorkflowLauncher:
            infoPlist?.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            if let shortcutName = customisation.launchShortcutName {
                print("patching \(customisation.module.description) to open workflow \(shortcutName)")
                infoPlist?.setValue("com.apple.shortcuts", forKey: "CCLaunchApplicationIdentifier")
                infoPlist?.setValue("com.apple.shortcuts", forKey: "CCAssociatedBundleIdentifier")
                infoPlist?.setValue("shortcuts://run-shortcut?name=" + shortcutName, forKey: "CCLaunchURL")
            }
        case .CustomAction:
            infoPlist?.setValue("CCUIAppLauncherModule", forKey: "NSPrincipalClass")
            print("customaction")

            print("patching \(customisation.module.description) to custom action")
            infoPlist?.setValue(Bundle.main.bundleIdentifier, forKey: "CCLaunchApplicationIdentifier")
            infoPlist?.setValue(Bundle.main.bundleIdentifier, forKey: "CCAssociatedBundleIdentifier")
            switch customisation.customAction {
            case .Respring:
                infoPlist?.setValue("controlconfig://respring", forKey: "CCLaunchURL")
            case .FrontboardRespring:
                if AppState.shared.debugMode { infoPlist?.setValue("controlconfig://respring?type=frontboard", forKey: "CCLaunchURL") }
                else { infoPlist?.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            case .BackboardRespring:
                if AppState.shared.debugMode { infoPlist?.setValue("controlconfig://respring?type=backboard", forKey: "CCLaunchURL") }
                else { infoPlist?.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            case .LegacyRespring:
                if AppState.shared.debugMode { infoPlist?.setValue("controlconfig://respring?type=legacy", forKey: "CCLaunchURL") }
                else { infoPlist?.setValue("controlconfig://respring", forKey: "CCLaunchURL") }
            }

        default:
            print("default")
        }

//        let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/\(AppState.shared.sbRegionCode).lproj/InfoPlist.strings"
//        if FileManager.default.fileExists(atPath: stringsPath) {
//            print("File exists")
//        }

        // doesnt work ios15
//        if ["HomeControlCenterCompactModule.bundle", "HomeControlCenterModule.bundle"].contains(customisation.module.fileName), let newName = CCMappings.moduleNames[customisation.module.fileName] as? String {
//            infoPlist?.setValue(newName, forKey: "CFBundleDisplayName")
//        }

        // PLIST PADDING ISSUE
//        if (customisation.hideAirplayText ?? false) == true || (customisation.hideFocusUIText ?? false) == true {
//            if #available(iOS 16, *) {
//                // code that should only run on iOS 16 or above
//                if customisation.module.fileName == "FocusUIModule.bundle" && customisation.hideFocusUIText == true {
//                    let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/Localizable.loctable"
//                    if var baseDict = NSMutableDictionary(contentsOfFile: stringsPath), var regionPart = baseDict[AppState.shared.sbRegionCode] as? [String: Any] {
//                        baseDict[AppState.shared.sbRegionCode] = [
//                            "MODULE_DEFAULT_TITLE": "",
//                            "MODULE_ON_STATE": ""
//                        ]
//                        print(baseDict)
//                        print("patch focusui strings ios16")
//                        successMap["focusText_16"] = (PlistHelpers.writeDictToPlist(dict: baseDict, path: stringsPath))
//                    }
//                }
//            } else {
//                let stringsPath = "\(CCMappings.bundlesPath)\(customisation.module.fileName)/\(AppState.shared.sbRegionCode).lproj/Localizable.strings"
//                if FileManager.default.fileExists(atPath: stringsPath) {
//                    if customisation.module.fileName == "FocusUIModule.bundle" && customisation.hideFocusUIText == true {
//                        print("patch focusui strings ios15")
//                        print([
//                            "MODULE_DEFAULT_TITLE": "",
//                            "MODULE_ON_STATE": ""
//                        ])
//                        successMap["focusText_15"] = PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: [
//                            "MODULE_DEFAULT_TITLE": "",
//                            "MODULE_ON_STATE": ""
//                        ]), path: stringsPath)
//                    }
//
//                    if customisation.module.fileName == "AirPlayMirroringModule.bundle" && customisation.hideAirplayText == true {
//                        if var dict = NSMutableDictionary(contentsOfFile: stringsPath) {
//                            dict["Screen Mirroring Compact"] = ""
//                            print("patch airplay strings ios15")
//                            print(dict)
//                            successMap["airplayText_15"] = PlistHelpers.writeDictToPlist(dict: dict, path: stringsPath)
//                        }
//                    }
//                }
//            }
//        }

        if let customName = customisation.customName {
            infoPlist?.setValue(customName, forKey: "CFBundleDisplayName")
        }

        if customisation.disableOnHoldWidget == true {
            infoPlist?.setValue(false, forKey: "CCSupportsApplicationShortcuts")
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
            emptyDMS[customisation.module.bundleID] = dict

            infoPlist?.setValue(dict, forKey: "_CCModuleSizePROTOTYPE") // useless but whatevers
        case .BothWays:
            let dict = [
                "width": customisation.customWidthBothWays ?? 1,
                "height": customisation.customHeightBothWays ?? 1
            ]
            infoPlist?.setValue(dict, forKey: "_CCModuleSizePROTOTYPE")
        case .None:
            // TODO: default size from backup

            if let backupDMS = BackupManager.shared.latestBackup?.defaultModuleSettings, let backupSize = backupDMS[newOg[customisation.module.bundleID] ?? customisation.module.bundleID] as? [String: Any] {
                if let bothWaySize = backupSize["size"] as? [String: Any] {
                    infoPlist?.setValue(bothWaySize, forKey: "_CCModuleSizePROTOTYPE")
                }
                emptyDMS[customisation.module.bundleID] = backupSize
            }
//            let dict = [
//                "width": 1,
//                "height": 1
//            ]
//            infoPlist?.setValue(dict, forKey: "_CCModuleSizePROTOTYPE")
        }

        if let dict = infoPlist {
            successMap["customInfo_\(customisation.module.fileName)"] = (PlistHelpers.writeDictToPlist(dict: dict, path: infoPath))
        }
    }

    if let keys = CCMappings.fileNameBasedSmallIDs.allKeys as? [String] {
        for moduleFileName in keys {
            let module = Module(fileName: moduleFileName)
            let infoPath = "\(CCMappings.bundlesPath)\(moduleFileName)/Info.plist"
            let infoPlist = PlistHelpers.plistToDict(path: infoPath)

            if emptyDMS[module.bundleID] != nil || infoPlist?["_CCModuleSizePROTOTYPE"] != nil { continue }

            if let backupDMS = BackupManager.shared.latestBackup?.defaultModuleSettings, let backupSize = backupDMS[newOg[module.bundleID] ?? module.bundleID] as? [String: Any] {
                if let bothWaySize = backupSize["size"] as? [String: Any] {
                    infoPlist?.setValue(bothWaySize, forKey: "_CCModuleSizePROTOTYPE")
                }
                emptyDMS[module.bundleID] = backupSize
            }

            if let dict = infoPlist {
                successMap["sizeInfo_\(moduleFileName)"] = PlistHelpers.writeDictToPlist(dict: dict, path: infoPath)
            }
        }
    }

    successMap["writeDMS"] = PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: emptyDMS), path: CCMappings().dmsPath)
//    if let c = customisations.otherCustomisations.moduleColor, let b = customisations.otherCustomisations.moduleBlur {
//        successMap["recipe_module"] = (ColorTools.applyMaterialRecipe(filePath: CCMappings.moduleMaterialRecipePath, color: c, blur: b, includeSpecificsForCCModules: true))
//    }
//    if let cB = customisations.otherCustomisations.moduleBGColor, let bB = customisations.otherCustomisations.moduleBGBlur {
//        successMap["recipe_moduleBackground"] = (ColorTools.applyMaterialRecipe(filePath: CCMappings.moduleBackgroundMaterialRecipePath, color: cB, blur: bB, includeSpecificsForCCModules: false))
//    }
//
    print("SuccessMap")
    do {
        let data = try JSONSerialization.data(withJSONObject: successMap, options: .prettyPrinted)
        if let prettyPrintedString = String(data: data, encoding: .utf8) {
            print(prettyPrintedString)
        }
    } catch {
        print(error.localizedDescription)
    }

//    print("successmap", successMap)
    return !successMap.values.contains { $0 == false }
}
