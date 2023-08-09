//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation

class AppState: Codable, ObservableObject {
    static let shared = AppState.loadFromUserDefaults()

    @Published var enableTipNotifications: Bool { didSet { saveToUserDefaults() } }
    @Published var enableConsole: Bool { didSet { saveToUserDefaults() } }
    @Published var useLegacyRespring: Bool { didSet { saveToUserDefaults() } }
    @Published var enableExperimentalFeatures: Bool { didSet { saveToUserDefaults() } }
    @Published var sbRegionCode: String { didSet { saveToUserDefaults() } }

    @Published var debugMode: Bool {
        didSet {
            saveToUserDefaults()
            if debugMode == false {
                enableConsole = false
                enableExperimentalFeatures = false
            }
        }
    }

    @Published var puaf_pages_index = 7 { didSet { saveToUserDefaults() } }
    @Published var puaf_pages = 0 { didSet { saveToUserDefaults() } }
    @Published var puaf_method = 1 { didSet { saveToUserDefaults() } }
    @Published var kread_method = 1 { didSet { saveToUserDefaults() } }
    @Published var kwrite_method = 1 { didSet { saveToUserDefaults() } }
    @Published var currentSet = CustomisationSet(bundleID: "com.uwuset", name: "ComLabs", list: [Customisation(module: Module(fileName: "Fake.bundle"))]) {
        didSet {
            print("hooked/s")
            saveToUserDefaults()
        }
    }
    
    private var subscribers: Set<AnyCancellable> = []
    

    private init(enableTipNotifications: Bool, enableConsole: Bool, useLegacyRespring: Bool, debugMode: Bool, enableExperimentalFeatures: Bool) {
        self.enableTipNotifications = enableTipNotifications
        self.enableConsole = enableConsole
        self.debugMode = debugMode
        self.useLegacyRespring = useLegacyRespring
        self.enableExperimentalFeatures = enableExperimentalFeatures
//        consoleManager.isVisible = enableConsole

        let deviceLanguageCode = Locale.current.languageCode ?? ""
        if CCMappings.hardcodedRegions.contains(deviceLanguageCode) { self.sbRegionCode = deviceLanguageCode }
        else if let regionCode = Locale.current.regionCode, CCMappings.hardcodedRegions.contains("\(deviceLanguageCode)_\(regionCode)") {
            self.sbRegionCode = "\(deviceLanguageCode)_\(regionCode)"
        } else {
            self.sbRegionCode = "en"
        }
        
        self.$currentSet.sink(receiveCompletion: { completion in
            print("Completion event: \(completion)")
        }, receiveValue: { updatedCurrentSet in
            print("Sink triggered with updated currentSet: \(updatedCurrentSet)")
        })
        .store(in: &subscribers)
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
        case currentSet
    }

//    enum CodingKeys: String, CodingKey {
//        case enableTipNotifications
//        case enableConsole
//        case useLegacyRespring
//        case debugMode
//        case enableExperimentalFeatures
//        case sbRegionCode
//
//        case puaf_pages_index
//        case puaf_pages
//        case puaf_method
//        case kread_method
//        case kwrite_method
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.enableTipNotifications = try container.decode(Bool.self, forKey: .enableTipNotifications)
//        self.enableConsole = try container.decode(Bool.self, forKey: .enableConsole)
//        self.useLegacyRespring = try container.decode(Bool.self, forKey: .useLegacyRespring)
//        self.debugMode = try container.decode(Bool.self, forKey: .debugMode)
//        self.sbRegionCode = try container.decode(String.self, forKey: .sbRegionCode)
//        self.enableExperimentalFeatures = try container.decode(Bool.self, forKey: .enableExperimentalFeatures)
//
//        self.puaf_pages_index = try container.decode(Int.self, forKey: .puaf_pages_index)
//        self.puaf_pages = try container.decode(Int.self, forKey: .puaf_pages)
//        self.puaf_method = try container.decode(Int.self, forKey: .puaf_method)
//        self.kread_method = try container.decode(Int.self, forKey: .kread_method)
//        self.kwrite_method = try container.decode(Int.self, forKey: .kwrite_method)
////        consoleManager.isVisible = enableConsole
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(enableTipNotifications, forKey: .enableTipNotifications)
//        try container.encode(enableConsole, forKey: .enableConsole)
//        try container.encode(useLegacyRespring, forKey: .useLegacyRespring)
//        try container.encode(debugMode, forKey: .debugMode)
//        try container.encode(sbRegionCode, forKey: .sbRegionCode)
//        try container.encode(enableExperimentalFeatures, forKey: .enableExperimentalFeatures)
//
//        try container.encode(puaf_pages_index, forKey: .puaf_pages_index)
//        try container.encode(puaf_pages, forKey: .puaf_pages)
//        try container.encode(puaf_method, forKey: .puaf_method)
//        try container.encode(kread_method, forKey: .kread_method)
//        try container.encode(kwrite_method, forKey: .kwrite_method)
//    }


    func saveToUserDefaults() {
        print("💾 Saving app state to defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appState")
        }
    }

    private static func loadFromUserDefaults() -> AppState {
        print("load usd, appstate")
        if let data = UserDefaults.standard.data(forKey: "appState"),
           let state = try? JSONDecoder().decode(AppState.self, from: data)
        {
            return state
        }
        
        return AppState(enableTipNotifications: true,enableConsole: false, useLegacyRespring: false, debugMode:false, enableExperimentalFeatures: false)
    }
}
