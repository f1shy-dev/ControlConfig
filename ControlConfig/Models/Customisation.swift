//
//  Customisation.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation

enum CustomisationMode: String, Codable {
    case AppLauncher, ModuleFunction, WorkflowLauncher
}

class Customisation: Codable, ObservableObject, Hashable {
    var isEnabled: Bool
    var module: Module
    @Published var mode: CustomisationMode

    init(module: Module) {
        self.module = module
        self.mode = .ModuleFunction
        self.isEnabled = false
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

    // default modules - width/height
    @Published var customWidthPortrait: Int?
    @Published var customHeightPortrait: Int?
    @Published var customWidthLandscape: Int?
    @Published var customHeightLandscape: Int?

    // name/icon
    @Published var customName: String?
//    var customIcon:

    @Published var disableOnHoldWidget: Bool?

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

        if (customWidthPortrait != nil) || (customHeightPortrait != nil) || (customWidthLandscape != nil) || (customHeightLandscape != nil) {
            str.append("Custom W/H")
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
        case customName
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
        self.customName = try? container.decode(String.self, forKey: .customName)
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
        try? container.encode(customName, forKey: .customName)
    }
}
