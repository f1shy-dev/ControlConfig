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

func applyChanges(customisations: CustomisationList) -> Result<Bool, Error> {
    let dmsPlist = PlistHelpers.plistToDict(path: CCMappings().dmsPath)

    for customisation in customisations.list {
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
            print("isdefaultmodule, didnt do much tho...")
        }

        if let dict = infoPlist {
            _ = PlistHelpers.writeDictToPlist(dict: dict, path: infoPath)
        }
    }
    return .success(true)
}
