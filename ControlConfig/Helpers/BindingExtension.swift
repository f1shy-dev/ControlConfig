//
//
// BindingExtension.swift
// ControlConfig
//
// Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

extension Binding where Value == Int? {
    var doubleBinding: Binding<Double> {
        Binding<Double>(
            get: {
                Double(self.wrappedValue ?? 0)
            },
            set: {
                self.wrappedValue = Int($0)
            }
        )
    }
}

extension Binding where Value == Int {
    var doubleBinding: Binding<Double> {
        Binding<Double>(
            get: {
                Double(self.wrappedValue)
            },
            set: {
                self.wrappedValue = Int($0)
            }
        )
    }
}
