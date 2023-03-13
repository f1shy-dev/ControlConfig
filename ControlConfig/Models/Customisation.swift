//
//  Customisation.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation

enum CustomisationMode: String, Codable {
    case AppLauncher, DefaultFunction, WorkflowLauncher, CustomAction
}

enum SizeMode: String, Codable {
    case Individual, BothWays, None
}

enum CustomAction: String, Codable {
    case Respring, BackboardRespring, FrontboardRespring, LegacyRespring
}

class Customisation: Codable, ObservableObject, Hashable {
    var isEnabled: Bool
    var module: Module
    @Published var mode: CustomisationMode
    @Published var customSizeMode: SizeMode

    init(module: Module) {
        self.module = module
        self.mode = .DefaultFunction
        self.isEnabled = false
        self.customSizeMode = .None

//        if module.isDefaultModule {
//            if let dmsTemp = PlistHelpers.plistToDict(path: CCMappings().dmsPath), let moduleDMSDict = dmsTemp[module.bundleID] as? NSMutableDictionary {
//                let sizes = module.sizesInDMSFile
//                if sizes.contains("size.height"), let h = moduleDMSDict.value(forKeyPath: "size.height") as? Int { self.customHeightBothWays = h }
//                if sizes.contains("size.width"), let h = moduleDMSDict.value(forKeyPath: "size.width") as? Int { self.customWidthBothWays = h }
//
//                if sizes.contains("portrait.size.height"), let h = moduleDMSDict.value(forKeyPath: "portrait.size.height") as? Int { self.customHeightPortrait = h }
//                if sizes.contains("portrait.size.width"), let h = moduleDMSDict.value(forKeyPath: "portrait.size.width") as? Int { self.customWidthPortrait = h }
//
//                if sizes.contains("landscape.size.height"), let h = moduleDMSDict.value(forKeyPath: "landscape.size.height") as? Int { self.customHeightLandscape = h }
//                if sizes.contains("landscape.size.width"), let h = moduleDMSDict.value(forKeyPath: "landscape.size.width") as? Int { self.customWidthLandscape = h }
//            }
//        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(isEnabled)
        hasher.combine(module.fileName)
        hasher.combine(module.bundleID)
    }

    static func ==(lhs: Customisation, rhs: Customisation) -> Bool {
        return lhs.module == rhs.module
    }

    // custom apps - asociated bundle id
    @Published var launchAppBundleID: String?
    @Published var launchAppURLScheme: String?

    // shortcuts using urlscheme
    @Published var launchShortcutName: String?

    // default modules - width/height (Int because sliders are Ints...)
    @Published var customWidthPortrait: Int?
    @Published var customHeightPortrait: Int?
    @Published var customWidthLandscape: Int?
    @Published var customHeightLandscape: Int?
    @Published var customWidthBothWays: Int?
    @Published var customHeightBothWays: Int?

    // name/icon
    @Published var customName: String?
//    var customIcon:

    @Published var disableOnHoldWidget: Bool?

//    @Published var hideAirplayText: Bool?
//    @Published var hideFocusUIText: Bool?

    @Published var customAction: CustomAction = .Respring

    var description: String {
        var str: [String] = []
        if mode == .AppLauncher {
            if let app = launchAppBundleID {
                str.append("Opens \"\(app)\"")
            }
        }

        if mode == .WorkflowLauncher {
            if let shortcut = launchShortcutName {
                str.append("Runs shortcut \"\(shortcut)\"")
            }
        }

        if mode == .CustomAction {
            str.append("Runs custom action")
        }

        if customSizeMode == .BothWays || customSizeMode == .Individual {
            str.append("Custom size")
        }

        if !(customName?.isEmpty ?? true) || (disableOnHoldWidget ?? false) {
            str.append("Extras")
        }

        if str.count > 0 {
            return str.joined(separator: ", ")
        }

        return "Doesn't do anything..."
    }

    enum CodingKeys: String, CodingKey {
        case isEnabled
        case module
        case mode

        case launchAppBundleID
        case launchAppURLScheme
        case disableOnHoldWidget
        case launchShortcutName

        case customWidthPortrait
        case customHeightPortrait
        case customWidthLandscape
        case customHeightLandscape
        case customWidthBothWays
        case customHeightBothWays

        case customSizeMode
        case customName
        case customAction

//        case hideAirplayText
//        case hideFocusUIText
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.module = try container.decode(Module.self, forKey: .module)
        self.mode = try container.decode(CustomisationMode.self, forKey: .mode)
        self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled)

        self.launchAppBundleID = try? container.decode(String.self, forKey: .launchAppBundleID)
        self.launchAppURLScheme = try? container.decode(String.self, forKey: .launchAppURLScheme)
        self.disableOnHoldWidget = try? container.decode(Bool.self, forKey: .disableOnHoldWidget)
        self.launchShortcutName = try? container.decode(String.self, forKey: .launchShortcutName)
        self.customWidthPortrait = try? container.decode(Int.self, forKey: .customWidthPortrait)
        self.customHeightPortrait = try? container.decode(Int.self, forKey: .customHeightPortrait)
        self.customWidthLandscape = try? container.decode(Int.self, forKey: .customWidthLandscape)
        self.customHeightLandscape = try? container.decode(Int.self, forKey: .customHeightLandscape)
        self.customWidthBothWays = try? container.decode(Int.self, forKey: .customWidthBothWays)
        self.customHeightBothWays = try? container.decode(Int.self, forKey: .customHeightBothWays)
        self.customName = try? container.decode(String.self, forKey: .customName)
        self.customAction = try container.decode(CustomAction.self, forKey: .customAction)
        self.customSizeMode = try container.decode(SizeMode.self, forKey: .customSizeMode)
//        self.hideAirplayText = try container.decode(Bool.self, forKey: .hideAirplayText)
//        self.hideFocusUIText = try container.decode(Bool.self, forKey: .hideFocusUIText)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(module, forKey: .module)
        try container.encode(mode, forKey: .mode)
        try container.encode(isEnabled, forKey: .isEnabled)

        try? container.encode(launchAppBundleID, forKey: .launchAppBundleID)
        try? container.encode(launchAppURLScheme, forKey: .launchAppURLScheme)
        try? container.encode(disableOnHoldWidget, forKey: .disableOnHoldWidget)
        try? container.encode(launchShortcutName, forKey: .launchShortcutName)

        try? container.encode(customWidthPortrait, forKey: .customWidthPortrait)
        try? container.encode(customHeightPortrait, forKey: .customHeightPortrait)

        try? container.encode(customWidthLandscape, forKey: .customWidthLandscape)
        try? container.encode(customHeightLandscape, forKey: .customHeightLandscape)

        try? container.encode(customWidthBothWays, forKey: .customWidthBothWays)
        try? container.encode(customHeightBothWays, forKey: .customHeightBothWays)

        try? container.encode(customSizeMode, forKey: .customSizeMode)
        try? container.encode(customName, forKey: .customName)
        try? container.encode(customAction, forKey: .customAction)

//        try? container.encode(hideFocusUIText, forKey: .hideFocusUIText)
//        try? container.encode(hideAirplayText, forKey: .hideAirplayText)
    }
}
