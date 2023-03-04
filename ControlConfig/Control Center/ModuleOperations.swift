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

func applyChanges(customisations: CustomisationList) -> Bool {
    let dmsPlistOriginal = PlistHelpers.plistToDict(path: CCMappings().dmsPath)
    var dmsPlist = PlistHelpers.plistToDict(path: CCMappings().dmsPath)

    var success: [Bool] = []

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

        if let customName = customisation.customName {
            infoPlist?.setValue(customName, forKey: "CFBundleDisplayName")
        }

        if customisation.disableOnHoldWidget == true {
            infoPlist?.setValue(false, forKey: "CCSupportsApplicationShortcuts")
        }

        if customisation.module.isDefaultModule {
            if let unwrappedDMSPlist = dmsPlist, let moduleDMSDict = unwrappedDMSPlist[customisation.module.bundleID] as? NSMutableDictionary {
                let sizes = customisation.module.sizesInDMSFile
                let keysToEdit = sizes.filter { $0.hasPrefix("size.") }
                let landscapeKeysToEdit = sizes.filter { $0.hasPrefix("landscape.size.") }
                let portraitKeysToEdit = sizes.filter { $0.hasPrefix("portrait.size.") }

                keysToEdit.forEach { key in
                    moduleDMSDict.setValue(key == "size.height" ? customisation.customHeightBothWays : customisation.customWidthBothWays, forKeyPath: key)
                }

                landscapeKeysToEdit.forEach { key in
                    moduleDMSDict.setValue(key == "landscape.size.height" ? customisation.customHeightLandscape : customisation.customWidthLandscape, forKeyPath: key)
                }

                portraitKeysToEdit.forEach { key in
                    moduleDMSDict.setValue(key == "portrait.size.height" ? customisation.customHeightPortrait : customisation.customWidthPortrait, forKeyPath: key)
                }

                unwrappedDMSPlist.setValue(moduleDMSDict, forKey: customisation.module.bundleID)
                dmsPlist = Optional(unwrappedDMSPlist)
            }
        }

        if let dict = infoPlist {
            success.append(PlistHelpers.writeDictToPlist(dict: dict, path: infoPath))
        }
    }

    if let new = dmsPlist {
        success.append(PlistHelpers.writeDictToPlist(dict: new, path: CCMappings().dmsPath))
    }

    ColorTools.applyMaterialRecipe(filePath: CCMappings.moduleMaterialRecipePath, color: customisations.otherCustomisations.moduleColor, blur: customisations.otherCustomisations.moduleBlur, includeSpecificsForCCModules: true)

    print("successmap", success)
    return !success.contains { $0 == false }
}
