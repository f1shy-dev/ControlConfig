//
//  CustomisationsList.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023.
//

import Foundation

class CustomisationList: ObservableObject {
    @Published var list: [Customisation] {
        didSet {
            DispatchQueue(label: "UserDefaultsSaver", qos: .background).async {
                print("saved something to USD")
                self.saveToUserDefaults()
            }
        }
    }

    init(list: [Customisation]) {
        self.list = list
    }

    init() {
        self.list = []
    }

    func addCustomisation(item: Customisation) {
        list.append(item)
        print(item.module.isDefaultModule)
        saveToUserDefaults()
    }

    func deleteCustomisation(item: Customisation) {
        if let index = list.firstIndex(where: { $0.module.bundleID == item.module.bundleID }) {
            list.remove(at: index)
        }
        saveToUserDefaults()
    }

    func saveToUserDefaults() {
        print("saving to user defaults...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(list) {
            UserDefaults.standard.set(encoded, forKey: "customisationList")
        }
    }

    static func loadFromUserDefaults() -> CustomisationList {
        if let data = UserDefaults.standard.data(forKey: "customisationList"), let items = try? JSONDecoder().decode([Customisation].self, from: data) {
            return CustomisationList(list: items)
        }
        return CustomisationList()
    }
}
