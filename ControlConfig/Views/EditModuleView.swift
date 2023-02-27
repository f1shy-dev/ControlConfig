//
//  EditModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI

struct EditModuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var customisation: Customisation

    var body: some View {
        var widthInt: Binding<Double> {
            Binding<Double>(get: {
                Double(customisation.customWidth ?? 2)
            }, set: {
                customisation.customWidth = Int($0)
            })
        }

        var heightInt: Binding<Double> {
            Binding<Double>(get: {
                Double(customisation.customHeight ?? 2)
            }, set: {
                customisation.customHeight = Int($0)
            })
        }

        return NavigationView {
            List {
                Picker("Action", selection: $customisation.mode) {
                    Text("App Launcher").tag(CustomisationMode.AppLauncher)
                    Text("CC Module").tag(CustomisationMode.ModuleFunction)
                    Text("Run Shortcut").tag(CustomisationMode.WorkflowLauncher)
                }.pickerStyle(.menu).id(customisation)

                switch customisation.mode {
                case .AppLauncher:
                    Section(header: Label("App Launcher", systemImage: "app.badge.checkmark"), footer: Text("The URL Scheme is to launch to a specific section of an app, such as com.apple.tv://us/show")) {
                        TextField("App Bundle ID", text: $customisation.launchAppBundleID.toUnwrapped(defaultValue: ""))
                        TextField("URL Scheme (optional)", text: $customisation.launchAppURLScheme.toUnwrapped(defaultValue: ""))
                    }
                case .WorkflowLauncher:
                    Section(header: Label("Open shortcut", systemImage: "arrow.up.forward.app"), footer: Text("Runs a specified Shortcut/Workflow when clicked. Note: Opens the shortcut app first (doesn't run in the background).")) {
                        TextField("Shortcut Name", text: $customisation.launchShortcutName.toUnwrapped(defaultValue: ""))
                    }
                case .ModuleFunction:
                    Section(header: Label("CC Module Functionality", systemImage: "square.on.square.intersection.dashed"), footer: Text("Set the module to have the function that it would have normally, or make it have the function of a different module")) {
                        Text("Hello!")
                    }
                }

                Section(header: Label("Looks", systemImage: "paintbrush")) {
                    TextField("Name", text: $customisation.customName.toUnwrapped(defaultValue: ""))
                }

                if customisation.module.isDefaultModule {
                    Section(header: Label("Sizing (Defualt Module)", systemImage: "ruler")) {
                        HStack {
                            Text("Width")
                            Spacer()
                            HStack {
                                Slider(
                                    value: widthInt,
                                    in: 1...4,
                                    step: 1
                                ) {
                                    Text("Width")
                                } minimumValueLabel: {
                                    Text("1")
                                } maximumValueLabel: {
                                    Text("4")
                                }

                            }.frame(width: 175)
                        }

                        HStack {
                            Text("Height")
                            Spacer()
                            HStack {
                                Slider(
                                    value: heightInt,
                                    in: 1...4,
                                    step: 1
                                ) {
                                    Text("Height")
                                } minimumValueLabel: {
                                    Text("1")
                                } maximumValueLabel: {
                                    Text("4")
                                }
                            }.frame(width: 175)
                        }
                    }
                }

                Section(header: Label("Other", systemImage: "star"), footer: Text("Disables the menu that shows up when you force-touch/hold down certain modules.")) {
                    Toggle("Disable Hold Menu", isOn: $customisation.disableOnHoldWidget.toUnwrapped(defaultValue: false))
                }
            }

            .navigationTitle("Edit \(customisation.module.description)")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Close", systemImage: "xmark")
                    })
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}
