//
//  EditModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Combine
import Foundation
import SwiftUI

struct LabelTextField: View {
    var label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", text: $value).keyboardType(.numberPad)
        }
    }
}

struct EditModuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var customisation: Customisation
    @ObservedObject var appState: AppState
    @State private var selectedMode: CustomisationMode
    @State var showingAppPickerSheet: Bool = false
    var saveToUserDefaults: () -> Void

    init(customisation: Customisation, appState: AppState, saveToUserDefaults: @escaping () -> Void) {
        self.customisation = customisation
        self.saveToUserDefaults = saveToUserDefaults
        self.appState = appState
        _selectedMode = State(initialValue: customisation.mode)
    }

    var body: some View {
        return NavigationView {
            List {
                Section(footer: customisation.mode == .DefaultFunction ? Text("This module will function as it normally would.") : Text("")) {
                    Picker("Action", selection: $customisation.mode) {
                        Text("Default Action").tag(CustomisationMode.DefaultFunction)
                        Text("App Launcher").tag(CustomisationMode.AppLauncher)
                        Text("Run Shortcut").tag(CustomisationMode.WorkflowLauncher)
                        Text("Custom Action").tag(CustomisationMode.CustomAction)
                    }
                    .pickerStyle(.automatic)
                    .id(customisation)
                    .onReceive(self.customisation.$mode) { _ in
                        customisation.objectWillChange.send()
                    }
                }

                switch customisation.mode {
                case .AppLauncher:
                    Section(header: Label("App Launcher", systemImage: "app.badge.checkmark"), footer: Text("The URL Scheme is to launch to a specific section of an app, such as com.apple.tv://us/show")) {
//                        if appState.enableExperimentalFeatures {
                        Button(action: {
                            self.showingAppPickerSheet = true
                        }) {
                            Label("Pick app from list (Beta)", systemImage: "checklist")
                        }.sheet(isPresented: $showingAppPickerSheet, content: {
                            AppListView(customisation: customisation)
                        })
//                        }
                        TextField("App Bundle ID", text: $customisation.launchAppBundleID.toUnwrapped(defaultValue: ""))
                        TextField("URL Scheme (optional)", text: $customisation.launchAppURLScheme.toUnwrapped(defaultValue: ""))
                    }
                case .WorkflowLauncher:
                    Section(header: Label("Open shortcut", systemImage: "arrow.up.forward.app"), footer: Text("Runs a specified Shortcut/Workflow when clicked. Note: Opens the shortcut app first (doesn't run in the background).")) {
                        TextField("Shortcut Name", text: $customisation.launchShortcutName.toUnwrapped(defaultValue: ""))
                    }
//                    Section(header: Label("Default Function", systemImage: "square.on.square"), footer:) {}
                case .CustomAction:
                    Section(header: Label("Custom Actions", systemImage: "terminal"), footer: Text("Make the module run a in-built custom action on click, mainly stuff you can't normally do. \(appState.enableExperimentalFeatures ? "Only use advanced actions if you know what you're doing..." : "")")) {
                        Picker("Action", selection: $customisation.customAction) {
                            Text("Respring").tag(CustomAction.Respring)
                            if appState.enableExperimentalFeatures {
                                Text("Frontboard Respring").tag(CustomAction.FrontboardRespring)
                                Text("Backboard Respring").tag(CustomAction.BackboardRespring)
                                Text("Legacy Respring").tag(CustomAction.LegacyRespring)
                            }
                        }
                        .pickerStyle(.automatic)
                        .id(customisation)
                        .onReceive(self.customisation.$customAction) { _ in
                            customisation.objectWillChange.send()
                        }
                    }
                case .DefaultFunction:
                    EmptyView()
                }

                Section(header: Label("Looks", systemImage: "paintbrush")) {
                    TextField("Name", text: $customisation.customName.toUnwrapped(defaultValue: ""))
                }

                let tooLarge = [customisation.customWidthPortrait, customisation.customHeightPortrait, customisation.customHeightLandscape, customisation.customWidthLandscape, customisation.customWidthBothWays, customisation.customHeightBothWays].contains { ($0 ?? 1) > 50 }
                Section(header: Label("Module Sizing", systemImage: "ruler"), footer: Text("\(tooLarge ? .init(" ⚠️ Warning: modules too large will cause performance issues.\n\n") : "")Sizes are measured in units of one-module, and default to the original size. Invidiual will let you pick a size for each orientation (portrait/landscape), Both orientations for a shared size between both.")) {
                    Picker("Sizing Mode", selection: $customisation.customSizeMode) {
                        Text("None").tag(SizeMode.None)
                        Text("Individual").tag(SizeMode.Individual)
                        Text("Both orientations").tag(SizeMode.BothWays)
                    }
                    .pickerStyle(.automatic)
                    .id(customisation)
                    .onReceive(self.customisation.$customSizeMode) { _ in
                        customisation.objectWillChange.send()
                    }

                    switch customisation.customSizeMode {
                    case .BothWays:
                        LabelTextField(label: "Height", value: $customisation.customHeightBothWays.intSafeBinding)
                        LabelTextField(label: "Width", value: $customisation.customWidthBothWays.intSafeBinding)
                    case .Individual:
                        LabelTextField(label: "Portrait Height", value: $customisation.customHeightPortrait.intSafeBinding)
                        LabelTextField(label: "Portrait Width", value: $customisation.customWidthPortrait.intSafeBinding)

                        LabelTextField(label: "Landscape Height", value: $customisation.customHeightLandscape.intSafeBinding)
                        LabelTextField(label: "Landscape Width", value: $customisation.customWidthLandscape.intSafeBinding)
                    case .None:
                        EmptyView()
                    }
                }

                Section(header: Label("Other", systemImage: "star"), footer: Text("Disables the menu that shows up when you force-touch/hold down certain modules.")) {
                    Toggle("Disable Hold Menu", isOn: $customisation.disableOnHoldWidget.toUnwrapped(defaultValue: false))

//                    if customisation.module.fileName == "FocusUIModule.bundle" {
//                        Toggle("Hide Focus Text", isOn: $customisation.hideFocusUIText.toUnwrapped(defaultValue: false))
//                    }
//
//                    if #available(iOS 16, *) {} else {
//                        if customisation.module.fileName == "AirPlayMirroringModule.bundle" {
//                            Toggle("Hide Screen Mirroring Text", isOn: $customisation.hideAirplayText.toUnwrapped(defaultValue: false))
//                        }
//                    }
                }

                if appState.debugMode {
                    Section(header: Label("Debug", systemImage: "ladybug")) {
                        Button("Print sizes in DMS") {
                            print(customisation.module.sizesInDMSFile)
                        }
                    }
                }
            }

            .navigationTitle("Edit \(customisation.module.description)")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        saveToUserDefaults()
                        dismiss()
                    }, label: {
                        Label("Close", systemImage: "xmark")
                    })
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}
