//
//  MainModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI

struct MainModuleView: View {
    @State private var showingAddNewSheet = false
    @State private var showingSettingsSheet = false
    @ObservedObject var customisations = CustomisationList.loadFromUserDefaults()
    @ObservedObject var appState = AppState.loadFromUserDefaults()

    var body: some View {
        let _ = print("redrawing home editor view")
        let _ = print(appState.enableConsole)

        NavigationView {
            VStack {
                if customisations.list.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "questionmark.app.dashed")
                            .font(.system(size: 55))
                            .padding()
                        Text("No Modules")
                            .font(.system(size: 30, weight: .semibold))

                        HStack {
                            Text("Press the")
                            Image(systemName: "plus.app")
                            Text("button below to add one!")
                        }
                    }
                    .padding()
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        ForEach(customisations.list, id: \.module.bundleID) { item in
                            CustomisationCard(customisation: item, deleteCustomisation: customisations.deleteCustomisation, saveToUserDefaults: customisations.saveToUserDefaults)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        applyChanges(customisations: customisations)
                        UIApplication.shared.confirmAlert(title: "Applied!", body: "Please respring to see any changes.", onOK: {}, noCancel: true)
//                        let success = overwriteModule(appBundleID: id, module: Module)
//                        if success {
//                            UIApplication.shared.alert(title: "Success", body: "Successfully wrote to file!", withButton: true)
//
//                            Haptic.shared.notify(.success)
//                        } else {
//                            UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
//
//                            Haptic.shared.notify(.error)
//                        }
                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    })

                    Button(action: {
                        MDC.respring()

                    }, label: {
                        Label("Respring", systemImage: "arrow.counterclockwise.circle")
                        Text("Respring")

                    })

                    Spacer()
                    Button(action: {
                        showingSettingsSheet.toggle()
//                        consoleManager.isVisible.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    }).sheet(isPresented: $showingSettingsSheet, onDismiss: {
                        appState.saveToUserDefaults()
                    }) {
                        SettingsView(appState: appState)
                    }

                    Button(action: {
                        showingAddNewSheet.toggle()
                    }, label: {
                        Label("Add Module", systemImage: "plus.app")
                    }).sheet(isPresented: $showingAddNewSheet) {
                        AddModuleView(customisations: customisations)
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
