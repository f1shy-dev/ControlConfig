//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Combine
import Foundation

class AppState: Codable, ObservableObject {
    
    @Published var enableConsole: Bool {
        didSet {
            consoleManager.isVisible = enableConsole
        }
    }

    @Published var useLegacyRespring: Bool

    init(enableConsole: Bool, useLegacyRespring: Bool) {
        self.enableConsole = enableConsole
        self.useLegacyRespring = useLegacyRespring
        consoleManager.isVisible = enableConsole
    }

    enum CodingKeys: String, CodingKey {
        case enableConsole
        case useLegacyRespring
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enableConsole = try container.decode(Bool.self, forKey: .enableConsole)
        self.useLegacyRespring = try container.decode(Bool.self, forKey: .useLegacyRespring)
        consoleManager.isVisible = enableConsole
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enableConsole, forKey: .enableConsole)
        try container.encode(useLegacyRespring, forKey: .useLegacyRespring)
    }

    func saveToUserDefaults() {
        print("saving app state to user defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appState")
        }
    }

    static func loadFromUserDefaults() -> AppState {
        if let data = UserDefaults.standard.data(forKey: "appState"),
           let state = try? JSONDecoder().decode(AppState.self, from: data)
        {
            return state
        }
        return AppState(enableConsole: false, useLegacyRespring: false)
    }
}
