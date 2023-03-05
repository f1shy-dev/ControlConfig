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
    @Published var moduleColor: Color
    @Published var moduleBlur: Int
    @Published var moduleBGColor: Color
    @Published var moduleBGBlur: Int

    init(moduleColor: Color, moduleBlur: Int, moduleBGColor: Color, moduleBGBlur: Int) {
        self.moduleColor = moduleColor
        self.moduleBlur = moduleBlur
        self.moduleBGColor = moduleBGColor
        self.moduleBGBlur = moduleBGBlur
    }

    enum CodingKeys: String, CodingKey {
        case moduleColor
        case moduleBlur
        case moduleBGColor
        case moduleBGBlur
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.moduleColor = try container.decode(Color.self, forKey: .moduleColor)
        self.moduleBlur = try container.decode(Int.self, forKey: .moduleBlur)
        self.moduleBGColor = try container.decode(Color.self, forKey: .moduleBGColor)
        self.moduleBGBlur = try container.decode(Int.self, forKey: .moduleBGBlur)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(moduleColor, forKey: .moduleColor)
        try container.encode(moduleBlur, forKey: .moduleBlur)
        try container.encode(moduleBGColor, forKey: .moduleBGColor)
        try container.encode(moduleBGBlur, forKey: .moduleBGBlur)
    }
}

class CustomisationList: ObservableObject {
    var list: [Customisation] {
        didSet {
            DispatchQueue(label: "UserDefaultsSaver", qos: .background).async {
//                print("saved something to USD")
                self.saveToUserDefaults()
            }
        }
    }

    @Published var otherCustomisations: OtherCustomisations {
        didSet {
            DispatchQueue(label: "UserDefaultsSaver", qos: .background).async {
                print("saved something to USD")
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
        let mpath = CCMappings.moduleMaterialRecipePath
        let mc = ColorTools.getMaterialRecipeColor(filePath: mpath)
        let mb = ColorTools.getMaterialRecipeBlur(filePath: mpath)

        let mBGpath = CCMappings.moduleBackgroundMaterialRecipePath
        let mBGc = ColorTools.getMaterialRecipeColor(filePath: mBGpath)
        let mBGb = ColorTools.getMaterialRecipeBlur(filePath: mBGpath)
        self.otherCustomisations = OtherCustomisations(moduleColor: mc, moduleBlur: mb, moduleBGColor: mBGc, moduleBGBlur: mBGb)
    }

    func addCustomisation(item: Customisation) {
        objectWillChange.send()
        list.append(item)
        print(item.module.isDefaultModule)
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
//        print("saving to user defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(list), let encodedOther = try? encoder.encode(otherCustomisations) {
            UserDefaults.standard.set(encoded, forKey: "customisationList")
            UserDefaults.standard.set(encodedOther, forKey: "otherCustomisations")
        }
    }

    static func loadFromUserDefaults() -> CustomisationList {
        if let data = UserDefaults.standard.data(forKey: "customisationList"), let items = try? JSONDecoder().decode([Customisation].self, from: data), let other = UserDefaults.standard.data(forKey: "otherCustomisations"), let otherDc = try? JSONDecoder().decode(OtherCustomisations.self, from: other) {
            return CustomisationList(list: items, otherCustomisations: otherDc)
        }
        return CustomisationList()
    }
}
