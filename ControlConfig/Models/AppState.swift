//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation

class AppState: Codable, ObservableObject {
    static let shared = AppState.loadFromDisk()

    @Published var enableTipNotifications: Bool = true
    @Published var enableConsole: Bool = false
    @Published var useLegacyRespring: Bool = false
    @Published var enableExperimentalFeatures: Bool = false
    @Published var sbRegionCode: String

    @Published var debugMode: Bool = false {
        didSet {
            if debugMode == false {
                enableConsole = false
                enableExperimentalFeatures = false
            }
        }
    }

    @Published var puaf_pages_index = 7
    @Published var puaf_pages = 0
    @Published var puaf_method = 1
    @Published var kread_method = 1
    @Published var kwrite_method = 1
    
    @Published var hybrid_apply_pre_tries = 2
    @Published var hybrid_apply_after_tries = 5
    @Published var hybrid_apply_kclose_when_done = true
    @Published var force_kfd_exploit = false {
        didSet {
            sendNotification(identifier: "force-kfd", title: "Debug: Force KFD", subtitle: "Please relaunch app to continue", secondsLater: 1, isRepeating: false)
            self.saveToDisk()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(1)
            }
        }
    }
    
    @Published var currentSet: CustomisationSet
    var savedSets: [CustomisationSet]
    var sets: [CustomisationSet] {
        [currentSet] + savedSets
    }
    
    @Published var currentIconPack: ExtractedIconPack?
    var savedIconPacks: [ExtractedIconPack]
    var iconPacks: [ExtractedIconPack] {
        if let current = currentIconPack {
            return savedIconPacks + [current]
        } else { return savedIconPacks }
    }
    
    private var cancellable: AnyCancellable?
    
    private init(enableTipNotifications: Bool, enableConsole: Bool, useLegacyRespring: Bool, debugMode: Bool, enableExperimentalFeatures: Bool, savedSets: [CustomisationSet], currentSet: CustomisationSet, savedIconPacks: [ExtractedIconPack], currentIconPack: ExtractedIconPack?) {
        self.enableTipNotifications = enableTipNotifications
        self.enableConsole = enableConsole
        self.debugMode = debugMode
        self.useLegacyRespring = useLegacyRespring
        self.enableExperimentalFeatures = enableExperimentalFeatures
        self.savedSets = savedSets
        self.currentSet = currentSet
        self.savedIconPacks = savedIconPacks
        self.currentIconPack = currentIconPack
        
        let deviceLanguageCode = Locale.current.languageCode ?? ""
        if CCMappings.hardcodedRegions.contains(deviceLanguageCode) { self.sbRegionCode = deviceLanguageCode }
        else if let regionCode = Locale.current.regionCode, CCMappings.hardcodedRegions.contains("\(deviceLanguageCode)_\(regionCode)") {
            self.sbRegionCode = "\(deviceLanguageCode)_\(regionCode)"
        } else {
            self.sbRegionCode = "en"
        }

        self._init_sink()
    }
    
    func _init_sink() {
        self.cancellable = self.currentSet.objectWillChange.sink { _ in
            print("[sink] currentset objectwillchange")
            self.objectWillChange.send()
        }
    }

    enum CodingKeys: CodingKey {
        case enableTipNotifications
        case enableConsole
        case useLegacyRespring
        case enableExperimentalFeatures
        case sbRegionCode
        case debugMode
        case puaf_pages_index
        case puaf_pages
        case puaf_method
        case kread_method
        case kwrite_method
        case hybrid_apply_pre_tries
        case hybrid_apply_after_tries
        case hybrid_apply_kclose_when_done
        case force_kfd_exploit
        case currentSet
        case savedSets
        case currentIconPack
        case savedIconPacks
    }
    
    func saveToDisk() {
        _debug_savedAppState_counter += 1
        print("💾 [\(_debug_savedAppState_counter)] Saving app state...")
        
        do {
            let encodedData = try JSONEncoder().encode(self)
            try encodedData.write(to: URL.documents.appendingPathComponent("app_state.json"))
        } catch let error {
            print("Failed to save app state. Error: \(error.localizedDescription)")
        }
    }
    
    private static func loadFromDisk() -> AppState {
        do {
            let data = try Data(contentsOf: URL.documents.appendingPathComponent("app_state.json"))
            let state = try JSONDecoder().decode(AppState.self, from: data)
            state._init_sink()
            state.currentSet._init_sink()
            return state
        } catch {
            return AppState(enableTipNotifications: true,enableConsole: false, useLegacyRespring: false, debugMode:false, enableExperimentalFeatures: false,savedSets: [], currentSet: CustomisationSet(bundleID: UUID().uuidString, name: "Default"), savedIconPacks: [], currentIconPack: nil)
        }
    }
}
