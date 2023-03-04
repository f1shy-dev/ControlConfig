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

    @Published var enableConsole: Bool {
        didSet {
            saveToUserDefaults()
            consoleManager.isVisible = enableConsole
        }
    }

    @Published var useLegacyRespring: Bool {
        didSet {
            saveToUserDefaults()
        }
    }

    @Published var debugMode: Bool {
        didSet {
            saveToUserDefaults()
            if debugMode == false {
                enableConsole = false
            }
        }
    }

    private init(enableConsole: Bool, useLegacyRespring: Bool, debugMode: Bool) {
        self.enableConsole = enableConsole
        self.debugMode = debugMode
        self.useLegacyRespring = useLegacyRespring
        consoleManager.isVisible = enableConsole
    }

    enum CodingKeys: String, CodingKey {
        case enableConsole
        case useLegacyRespring
        case debugMode
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enableConsole = try container.decode(Bool.self, forKey: .enableConsole)
        self.useLegacyRespring = try container.decode(Bool.self, forKey: .useLegacyRespring)
        self.debugMode = try container.decode(Bool.self, forKey: .debugMode)
        consoleManager.isVisible = enableConsole
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enableConsole, forKey: .enableConsole)
        try container.encode(useLegacyRespring, forKey: .useLegacyRespring)
        try container.encode(debugMode, forKey: .debugMode)
    }

    func saveToUserDefaults() {
//        print("saving app state to user defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appState")
        }
    }

    private static func loadFromUserDefaults() -> AppState {
        if let data = UserDefaults.standard.data(forKey: "appState"),
           let state = try? JSONDecoder().decode(AppState.self, from: data)
        {
            return state
        }
        return AppState(enableConsole: false, useLegacyRespring: false, debugMode: false)
    }
}
