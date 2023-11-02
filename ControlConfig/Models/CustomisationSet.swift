//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation
import SwiftUI

class CustomisationSet: Codable, ObservableObject, Hashable, Identifiable {
    var id: String { bundleID }
    let bundleID: String
    let name: String
    let publisher: String?
    @Published var moduleColor: Color?
    @Published var moduleBlur: Int?
    @Published var moduleBGColor: Color?
    @Published var moduleBGBlur: Int?
    @Published var enableCustomColors: Bool
    @Published var list: [Customisation]
    
    var cancellable: AnyCancellable?
    
    init(bundleID: String, name: String, publisher: String? = nil, moduleColor: Color? = nil, moduleBlur: Int? = nil, moduleBGColor: Color? = nil, moduleBGBlur: Int? = nil, enableCustomColors: Bool = false, list: [Customisation]? = nil) {
        self.bundleID = bundleID
        self.name = name
        self.publisher = publisher
        self.moduleColor = moduleColor
        self.moduleBlur = moduleBlur
        self.moduleBGColor = moduleBGColor
        self.moduleBGBlur = moduleBGBlur
        self.enableCustomColors = enableCustomColors
        
        if let list = list {
            self.list = list
        } else {
            self.list = []
            var temp_modules: [Module] = []
            if activeExploit == .MDC, let dict = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath), let list = dict["module-identifiers"] as? [String] {
                for module in list {
                    if let mod = Module(bundleID: module) {
                        temp_modules.append(mod)
                    }
                }
                
                if let keys = CCMappings.fileNameBasedSmallIDs.allKeys as? [String], !(self.list.contains { keys.contains($0.module.fileName) }) {
                    temp_modules.insert(contentsOf: [
                        "ConnectivityModule.bundle",
                        "MediaControlsModule.bundle",
                        "OrientationLockModule.bundle",
                        "AirPlayMirroringModule.bundle",
                        "DisplayModule.bundle",
                        "MediaControlsAudioModule.bundle",
                        "FocusUIModule.bundle",
                        "HomeControlCenterModule.bundle",
                    ].map({Module(fileName: $0)}), at: 0)
                }
            }
            var seen = Set<Module>()
            temp_modules = temp_modules.filter{ seen.insert($0).inserted }.filter{ $0.fileName.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
            self.list = temp_modules.map{ Customisation(module: $0) }
        }
        
        self._init_sink()
    }
    
    func _init_sink() {
        self.cancellable = self.$list.dropFirst().sink { [weak self] _ in
            print("[sink] customisationSet.$list")
            self?.objectWillChange.send()
        }
    }
    
    static func == (lhs: CustomisationSet, rhs: CustomisationSet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: CodingKey {
        case bundleID
        case name
        case publisher
        case moduleColor
        case moduleBlur
        case moduleBGColor
        case moduleBGBlur
        case enableCustomColors
        case list
    }
}
