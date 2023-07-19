//
//  MainModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI
import WelcomeSheet

struct MainModuleView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingFirstLaunchSheet = true
    @State private var showingAddNewSheet = false
    @State private var showingSettingsSheet = false
    @ObservedObject var customisations = CustomisationList.loadFromUserDefaults()
    @ObservedObject var appState = AppState.shared

    var body: some View {
        NavigationView {
            VStack {
                List {
//                    Section(header: Label("General Customisations", systemImage: "paintbrush.pointed")) {
                    Section {
                        NavigationLink {
                            EditCCColorsView(state: customisations.otherCustomisations, saveOCToUserDefaults: customisations.saveToUserDefaults)
                        } label: {
                            Label("Edit CC Colours", systemImage: "paintbrush")
                        }

                        if appState.enableExperimentalFeatures {
                            NavigationLink {
                                AllIconsEditorView(customisations: customisations)
                            } label: {
                                Label("CC Icons Editor", systemImage: "paintbrush")
                            }
                            
                            NavigationLink {
                                ExploreView()
                            } label: {
                                Label("Explore", systemImage: "safari")
                            }
                            
                            NavigationLink{
                                CAMLEditorView(caFolderPath: "/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle/replaykit.ca")
                            } label: {
                                Label("CAML Editor - ReplayKit", systemImage: "pencil")
                            }
                        }
                    }

                    if customisations.list.isEmpty {
                        Section(header: Label("Modules", systemImage: "app.dashed"), footer: Text("You don't have any control center modules - press the \(Image(systemName: "plus.app")) button below to add one!")) {}.headerProminence(.increased)
                    } else {
//                        Section(header: Label("Module Customisations", systemImage: "app.dashed")) {
                        Section(header:                HStack {
                            Text("Modules")
                            Spacer()
                            Button {
                                UIApplication.shared.alert(title: "Info - Modules", body:"Unlike older versions of the app, this list of modules here mirrors what you would see in iOS Settings.\n\nThis means that you can now reorder your modules in-app, by either holding and moving the items around in the modules list, or by going into re-order mode by pressing Edit at the top left of the screen.\n\nThis makes everything easier and faster, and you don't have to mess with the order in settings anymore.")
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            
                        }
                            ){
                            ForEach(customisations.list, id: \.module.bundleID) { item in

                                CustomisationCard(customisation: item, appState: appState, deleteCustomisation: customisations.deleteCustomisation, saveToUserDefaults: customisations.saveToUserDefaults) {
                                    customisations.objectWillChange.send()
                                }
                            }.onMove { from, to in
                                customisations.list.move(fromOffsets: from, toOffset: to)
                                customisations.saveToUserDefaults()
                                customisations.objectWillChange.send()
                            }
                            .onDelete { idxset in
                                withAnimation {
                                    customisations.list.remove(atOffsets: idxset)
                                    customisations.saveToUserDefaults()
                                    customisations.objectWillChange.send()
                                }
                            }
                        }.headerProminence(.increased)
                    }
                }
                .listRowInsets(.none)
            }
//            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettingsSheet.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    }).sheet(isPresented: $showingSettingsSheet, onDismiss: {
                        appState.saveToUserDefaults()
                    }) {
                        SettingsView(appState: appState, customisations: customisations)
                    }
                }
                ToolbarItemGroup {
                    EditButton()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let success = applyChanges(customisations: customisations)
                            DispatchQueue.main.async {
                                if success.0 {
                                    let smsg = success.1.count == 0 ? "Everything's already applied (nothing changed on disk)." : "\(success.1.count) operation\(success.1.count < 2 ? "": "s") were completed successfully."
                                    Haptic.shared.notify(.success)
                                    UIApplication.shared.confirmAlert(title: "✅ Success", body: "\(smsg) Please respring to see any changes.", onOK: {}, noCancel: true)
                                } else {
                                    Haptic.shared.notify(.error)
                                    let failed = success.1.filter { $0.value == false }.map { $0.key }.joined(separator: "\n")
//                                    UIApplication.shared.alert(title: "⛔️ Error", body: "An error occurred when writing to the file(s). First please try rebooting your device, and if it does not work, please report this to the developer and provide any logs/details of what you tried.")
                                    UIApplication.shared.alert(title: "⛔️ Error", body: "An error occured while applying your modules and customisiations. The write operations that failed are: \n\n\(failed)\n\nPlease adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried.")
                                }
                            }
                        }

                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    })
//                    .disabled(
//                        customisations.list.filter { c in c.isEnabled }.isEmpty &&
//                            [customisations.otherCustomisations.moduleBlur, customisations.otherCustomisations.moduleBGBlur].allSatisfy { ($0 as Int?) == nil } &&
//                            [customisations.otherCustomisations.moduleColor, customisations.otherCustomisations.moduleBGColor].allSatisfy { ($0 as Color?) == nil }
//                    )

                    Spacer()

                    Button(action: {
                        Haptic.shared.play(.light)
                        showingAddNewSheet.toggle()
                    }, label: {
                        Label("Add Module", systemImage: "plus.app")

                    }).sheet(isPresented: $showingAddNewSheet) {
                        AddModuleView(customisations: customisations)
                    }

                    Spacer()

                    Button(action: {
                        MDC.respring(method: appState.useLegacyRespring ? .legacy : .frontboard)

                    }, label: {
                        Label("Respring", systemImage: "arrow.triangle.2.circlepath.circle")
                        Text("Respring")
                    }).contextMenu {
                        
                        Button {
                            MDC.respring(method: .frontboard)
                        } label: {
                            Label("Frontboard Respring", systemImage: "arrow.triangle.2.circlepath")
                        }

                        Button {
                            MDC.respring(method: .backboard)
                        } label: {
                            Label("Backboard Respring", systemImage: "arrow.2.squarepath")
                        }
                        
                        Button {
                            MDC.respring(method: .legacy)
                        } label: {
                            Label("Legacy Respring", systemImage: "arrow.rectanglepath")
                        }
                    }
                }
            }

        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainModule_Previews: PreviewProvider {
    static var previews: some View {
        MainModuleView()
    }
}
