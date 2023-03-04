//
//  SettingsView.swift
//  ControlConfig
//
//  Created by f1shy-dev some time in the last 47 years.
//

import Foundation
import LocalConsole
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appState: AppState
    @ObservedObject var customisations: CustomisationList

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Use old respring", isOn: $appState.useLegacyRespring)
                } header: {
                    Label("Respring", systemImage: "arrow.counterclockwise")
                } footer: {
                    Label("Only enable if respringing doesn't work.", systemImage: "info.circle")
                }
                Section(header: Label("Debug", systemImage: "ladybug"), footer: Label("Settings meant for people who know what they're doing. Only touch anything here if the developers explicitly told you to.", systemImage: "info.circle")) {
                    Button("Export app logs") {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        if let encoded = try? encoder.encode(customisations.list) {
                            if customisations.list.isEmpty {
                                print("customisation list EMPTY")
                            } else {
                                print("customisation list")
                                print(String(data: encoded, encoding: .utf8)!)
                            }
                        }

                        print("""
                        Model Name:         \(SystemReport.shared.gestaltMarketingName)
                        Model Identifier:   \(SystemReport.shared.gestaltModelIdentifier)
                        Architecture:       \(SystemReport.shared.gestaltArchitecture)
                        Firmware:           \(SystemReport.shared.gestaltFirmwareVersion)
                        Kernel Version:     \(SystemReport.shared.kernel) \(SystemReport.shared.kernelVersion)
                        System Version:     \(SystemReport.shared.versionString)
                        OS Compile Date:    \(SystemReport.shared.compileDate)
                        Memory:             \(round(100 * Double(ProcessInfo.processInfo.physicalMemory) * pow(10, -9)) / 100) GB
                        Processor Cores:    \(Int(ProcessInfo.processInfo.processorCount))
                        """)
                        UIPasteboard.general.string = consoleManager.getCurrentText()
                        UIApplication.shared.confirmAlert(title: "Success", body: "Copied app logs to clipboard.", onOK: {}, noCancel: true)
                    }
                    Toggle("Enable debug mode", isOn: $appState.debugMode)
                    if appState.debugMode {
                        Toggle("Enable in-app console", isOn: $appState.enableConsole)
                        Toggle("Enable Experimental Features", isOn: $appState.enableExperimentalFeatures)
                    }
                }
                Section {} header: {
                    VStack {
                        Text("ControlConfig \(appVersion)\nMade with \(Image(systemName: "heart.fill")) by sneakyf1shy & BomberFish.")
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
