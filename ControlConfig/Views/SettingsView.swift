//
//  SettingsView.swift
//  ControlConfig
//
//  Created by f1shy-dev some time in the last 47 years.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Debug", systemImage: "ladybug"), footer: Text("Settings meant for developers, or if the developers told you to come here.")) {
                    Toggle("Enable in-app console", isOn: $appState.enableConsole)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        appState.saveToUserDefaults()
                        dismiss()
                    }, label: {
                        Label("Close", systemImage: "xmark")
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("App Settings")
        }
    }
}
