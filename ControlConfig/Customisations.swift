//
//  Customisations.swift
//  ControlConfig
//
//  Created by Vrishank Agarwal on 09/02/2023.
//

import Foundation
import SwiftUI

let bundlesPath = "/System/Library/ControlCenter/Bundles/"

let bundleBasedModuleNameOverrides: NSDictionary = [
    "com.apple.shazamkit.controlcenter.ShazamModule": "Shazam",
    "com.apple.control-center.DisplayModule": "Brightness",
    "com.apple.mediaremote.controlcenter.nowplaying": "Media Player",
    "com.apple.Home.ControlCenter": "Home (large)",
    "com.apple.mediaremote.controlcenter.audio": "Volume"
    // TODO: mediacontrolsaudio, silencecallsccwidget and others
]

let bundleBasedSFIcons: NSDictionary = [
    "com.apple.replaykit.VideoConferenceControlCenterModule": "video",
    "com.apple.FocusUIModule": "moon",
    "com.apple.Home.ControlCenter": "homekit",
    "com.apple.control-center.DisplayModule": "sun.max",
    "com.apple.mediaremote.controlcenter.audio": "speaker.wave.2",
    "com.apple.control-center.ConnectivityModule": "wifi",
    "com.apple.replaykit.AudioConferenceControlCenterModule": "mic",
    "com.apple.mediaremote.controlcenter.nowplaying": "waveform"
]

// MARK: - CC Module struct

struct CCModule: Hashable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    var fileName: String

    var isDefaultModule: Bool {
        let fileDict = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/ControlCenterUI.framework/DefaultModuleSettings~iphone.plist")
        print(fileDict?.allKeys as Any)
        return fileDict?.allKeys.contains(where: { key in
            bundleID == "\(key)"
        }) == true
    }

    var sfIcon: String {
        if let icon = bundleBasedSFIcons[bundleID] {
            return "\(icon)"
        }
        return "app.dashed"
    }

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

enum CustomisationMode: String, Codable {
    case AppLauncher, ModuleFunction, WorkflowLauncher
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
// MARK: - CC Customization struct

struct CCCustomisation: Codable {
    var isEnabled: Bool
    var module: CCModule
    var mode: CustomisationMode
    
    // custom apps - asociated bundle id
    var launchAppBundleID: String?
    var launchAppURLScheme: String?
    
    // shortcuts using urlscheme
    var launchShortcutName: String?
    
    // default modules - width/height
    var customWidth: Int?
    var customHeight: Int?
    
    // name/icon
    var customName: String?
//    var customIcon:
    
    var disableOnHoldWidget: Bool?

    
    var description: String {
        var str: [String] = []
        if let app = launchAppBundleID {
            str.append("Opens \(app)")
        }

        if (self.customWidth != nil) || (self.customHeight != nil) {
            str.append("Custom W/H")
        }

        if str.count > 0 {
            return str.joined(separator: ",")
        }

        return "Doesn't do anything..."
    }


    enum CodingKeys: String, CodingKey {
        case isEnabled
        case module
        case launchAppBundleID
        case customWidth
        case customHeight
        case mode
    }
}

// MARK: - Overwrite Module

func overwriteModule(appBundleID: String, module: CCModule) -> Bool {
    if module.bundleID == "com.apple.control-center.MagnifierModule" {
        return plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCLaunchApplicationIdentifier", value: appBundleID)
    }

    let patch1 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "CCAssociatedBundleIdentifier", value: appBundleID)
    let patch2 = plistChangeStr(plistPath: "\(bundlesPath)\(module.fileName)/Info.plist", key: "NSPrincipalClass", value: "CCUIAppLauncherModule")

    return (patch1 && patch2)
}

// MARK: - Get modules

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

extension UserDefaults {
    @objc dynamic var customisations: String { // helper keypath
        return string(forKey: "customisations") ?? ""
    }
}

class CustomisationList: ObservableObject {
    @Published var list: [CCCustomisation] {
        didSet {
            self.saveToUserDefaults()
        }
    }

    init(list: [CCCustomisation]) {
        self.list = list
    }

    init() {
        self.list = []
    }

    func addCustomisation(item: CCCustomisation) {
        self.list.append(item)
        print(item.module.isDefaultModule)
    }

    func deleteCustomisation(item: CCCustomisation) {
        if let index = self.list.firstIndex(where: { $0.module.bundleID == item.module.bundleID }) {
            self.list.remove(at: index)
        }
    }

    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.list) {
            UserDefaults.standard.set(encoded, forKey: "customisationList")
        }
    }

    static func loadFromUserDefaults() -> CustomisationList {
        if let data = UserDefaults.standard.data(forKey: "customisationList"), let items = try? JSONDecoder().decode([CCCustomisation].self, from: data) {
            return CustomisationList(list: items)
        }
        return CustomisationList()
    }
}
