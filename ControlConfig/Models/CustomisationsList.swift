//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation
import SwiftUI

class OtherCustomisations: ObservableObject, Codable {
    @Published var moduleColor: Color?
    @Published var moduleBlur: Int?
    @Published var moduleBGColor: Color?
    @Published var moduleBGBlur: Int?
    @Published var enableCustomColors: Bool?

    init(moduleColor: Color, moduleBlur: Int, moduleBGColor: Color, moduleBGBlur: Int, enableCustomColors: Bool) {
        self.moduleColor = moduleColor
        self.moduleBlur = moduleBlur
        self.moduleBGColor = moduleBGColor
        self.moduleBGBlur = moduleBGBlur
        self.enableCustomColors = enableCustomColors
    }

    init() {}

    enum CodingKeys: String, CodingKey {
        case moduleColor
        case moduleBlur
        case moduleBGColor
        case moduleBGBlur
        case enableCustomColors
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.moduleColor = try? container.decode(Color.self, forKey: .moduleColor)
        self.moduleBlur = try? container.decode(Int.self, forKey: .moduleBlur)
        self.moduleBGColor = try? container.decode(Color.self, forKey: .moduleBGColor)
        self.moduleBGBlur = try? container.decode(Int.self, forKey: .moduleBGBlur)
        self.enableCustomColors = try? container.decode(Bool.self, forKey: .enableCustomColors)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(moduleColor, forKey: .moduleColor)
        try container.encode(moduleBlur, forKey: .moduleBlur)
        try container.encode(moduleBGColor, forKey: .moduleBGColor)
        try container.encode(moduleBGBlur, forKey: .moduleBGBlur)
        try container.encode(enableCustomColors, forKey: .enableCustomColors)
    }
}

class CustomisationList: ObservableObject {
    
    var list: [Customisation] {
        didSet {
            DispatchQueue(label: "UserDefaultsSaver", qos: .background).async {
                self.saveToUserDefaults()
            }
        }
    }

    @Published var otherCustomisations: OtherCustomisations {
        didSet {
            DispatchQueue(label: "UserDefaultsSaver", qos: .background).async {
                self.saveToUserDefaults()
            }
        }
    }

    init(list: [Customisation], otherCustomisations: OtherCustomisations) {
        self.list = list
        self.otherCustomisations = otherCustomisations
    }

    init() {
        self.list = []
        var temp_modules: [Module] = []
        if let dict = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath), let list = dict["module-identifiers"] as? [String] {
                for module in list {
                    if let mod = Module(bundleID: module) {
                        temp_modules.append(mod)
                    }
                }
            
            if let keys = CCMappings.fileNameBasedSmallIDs.allKeys as? [String],  !(self.list.contains {
                keys.contains($0.module.fileName)
            }) {
                temp_modules.insert(contentsOf: [
                    "ConnectivityModule.bundle",
                    "MediaControlsModule.bundle",
                    "OrientationLockModule.bundle",
                    "AirPlayMirroringModule.bundle",
                    "DisplayModule.bundle",
                    "MediaControlsAudioModule.bundle",
                    "FocusUIModule.bundle",
                    "HomeControlCenterModule.bundle",
                ].map({ mo in
                    Module(fileName: mo)
                }), at: 0)
            }
        }
        
        //safety net for duplicate modules from the file or idfk
        var seen = Set<Module>()
        temp_modules = temp_modules.filter{ seen.insert($0).inserted }.filter{ $0.fileName.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        self.list = temp_modules.map{ Customisation(module: $0) }
        
        let mpath = CCMappings.moduleMaterialRecipePath
        let mc = ColorTools.getMaterialRecipeColor(filePath: mpath, isCCModule: true)
        let mb = ColorTools.getMaterialRecipeBlur(filePath: mpath)

        let mBGpath = CCMappings.moduleBackgroundMaterialRecipePath
        let mBGc = ColorTools.getMaterialRecipeColor(filePath: mBGpath, isCCModule: false)
        let mBGb = ColorTools.getMaterialRecipeBlur(filePath: mBGpath)
        self.otherCustomisations = OtherCustomisations(moduleColor: mc, moduleBlur: mb, moduleBGColor: mBGc, moduleBGBlur: mBGb, enableCustomColors: false)
        self.saveToUserDefaults()
    }

    func addCustomisation(item: Customisation) {
        objectWillChange.send()
        list.append(item)
//        print(item.module.isDefaultModule)
        Haptic.shared.play(.soft)
        saveToUserDefaults()
    }

    func deleteCustomisation(item: Customisation) {
        objectWillChange.send()
        if let index = list.firstIndex(where: { $0.module.bundleID == item.module.bundleID }) {
            list.remove(at: index)
        }
        saveToUserDefaults()
    }

    func saveToUserDefaults() {
        print("💾 Saving customisations to defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(list), let encodedOther = try? encoder.encode(otherCustomisations) {
            UserDefaults.standard.set(encoded, forKey: "customisationList")
            UserDefaults.standard.set(encodedOther, forKey: "otherCustomisations")
            UserDefaults.standard.set(2, forKey: "storageVersion")
        }
    }

    static func loadFromUserDefaults() -> CustomisationList {
        do {
            guard let data = UserDefaults.standard.data(forKey: "customisationList") else { throw GenericError.MissingCL}
            let items = try JSONDecoder().decode([Customisation].self, from: data)
            guard let other = UserDefaults.standard.data(forKey: "otherCustomisations") else { throw GenericError.MissingOC }
            let otherDc = try JSONDecoder().decode(OtherCustomisations.self, from: other)
            guard UserDefaults.standard.integer(forKey: "storageVersion") == 2 else { throw GenericError.OldStorageVersion }

            print("🗄️ Loaded saved customisations from defaults...")
            return CustomisationList(list: items, otherCustomisations: otherDc)
        }
        catch {
            if error as? GenericError == .MissingCL {
                print("⛔️ CustomisationList missing in defaults - using blank state")
            } else if error as? GenericError == .MissingOC {
                print("⛔️ OtherCustomisations missing in defaults - using blank state")
            } else if error as? GenericError == .OldStorageVersion {
                print("⛔️ UserDefaults isnt updated to storage version v2!")
                if UserDefaults.standard.data(forKey: "customisationList") != nil {
                    UserDefaults.standard.removeObject(forKey: "customisationList")
                }
                if UserDefaults.standard.data(forKey: "otherCustomisations") != nil {
                    UserDefaults.standard.removeObject(forKey: "otherCustomisations")
                }
                UIApplication.shared.alert(title: "Storage Error", body: "Due to a re-write in how the modules system works, ControlConfig had to delete any previous customisations you had setup. You'll now start from a blank state, mirroring your iOS settings...")
            } else {print("⛔️ Error loading customisations: \(error.localizedDescription) - using blank state")}
            return CustomisationList()
        }
    }
}
