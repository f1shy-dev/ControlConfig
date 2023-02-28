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

    init(enableConsole: Bool) {
        self.enableConsole = enableConsole
        consoleManager.isVisible = enableConsole
    }

    enum CodingKeys: String, CodingKey {
        case enableConsole
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enableConsole = try container.decode(Bool.self, forKey: .enableConsole)
        consoleManager.isVisible = enableConsole
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enableConsole, forKey: .enableConsole)
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
        return AppState(enableConsole: false)
    }
}
