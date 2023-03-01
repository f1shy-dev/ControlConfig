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

    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Use Old Respring", isOn: $appState.useLegacyRespring)
                } header: {
                    Label("Respring", systemImage: "arrow.counterclockwise")
                } footer: {
                    Label("Only enable if respringing doesn't work.", systemImage: "info.circle")
                }
                Section(header: Label("Debug", systemImage: "ladybug"), footer: Label("Settings meant for people who know what they're doing. Only touch anything here if the developers explicitly told you to.", systemImage: "info.circle")) {
                    Button("Copy app logs") {
                        consoleManager.systemReport()
                        consoleManager.copyToClipboard()
                        UIApplication.shared.confirmAlert(title: "Success", body: "Copied app logs to clipboard.", onOK: {}, noCancel: true)
                    }
                    Toggle("Enable debug mode", isOn: $appState.debugMode)
                    if appState.debugMode {
                        Toggle("Enable in-app console", isOn: $appState.enableConsole)
                    }
                }
                Section {} header: {
                    VStack {
                        Text("ControlConfig \(appVersion)\nMade with \(Image(systemName: "heart.fill")) by two fish.")
                    }
                }.textCase(.none)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
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
