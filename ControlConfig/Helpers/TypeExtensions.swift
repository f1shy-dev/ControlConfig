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

    var intSafeBinding: Binding<String> {
        Binding<String>(
            get: {
                if self.wrappedValue == nil { return "" }
                return String(self.wrappedValue ?? 1)
            },
            set: {
                if $0 == "" {
                    self.wrappedValue = nil
                } else {
                    self.wrappedValue = Int($0) ?? 1
                }
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

    var intSafeBinding: Binding<String> {
        Binding<String>(
            get: { String(self.wrappedValue) },
            set: { self.wrappedValue = Int($0) ?? 0 }
        )
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

// Turn a string into a threeletter/number code
extension String {
    func checksum() -> String {
        return "\(self.prefix(1))\(String(format: "%02x", self.utf8.reduce(0) { $0 ^ $1 }))"
    }
}
