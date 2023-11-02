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

    @Published var hideAirplayText: Bool = false
    @Published var hideFocusUIText: Bool = false

    @Published var customAction: CustomAction = .Respring

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

        case hideAirplayText
        case hideFocusUIText
    }
}
