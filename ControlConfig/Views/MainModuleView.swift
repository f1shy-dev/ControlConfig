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
                        Text("Press the \(Image(systemName: "plus.app")) button below to add one!")
                    }
                    .padding()
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        ForEach(customisations.list, id: \.module.bundleID) { item in
                            CustomisationCard(customisation: item, appState: appState, deleteCustomisation: customisations.deleteCustomisation, saveToUserDefaults: customisations.saveToUserDefaults)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettingsSheet.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    }).sheet(isPresented: $showingSettingsSheet, onDismiss: {
                        appState.saveToUserDefaults()
                    }) {
                        SettingsView(appState: appState)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        let success = applyChanges(customisations: customisations)
                        if success {
                            Haptic.shared.notify(.success)
                            UIApplication.shared.confirmAlert(title: "Applied!", body: "Please respring to see any changes.", onOK: {}, noCancel: true)
                        } else {
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(body: "An error occurred when writing to the file(s).")
                        }
                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    })
                    .disabled(customisations.list.isEmpty)

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
                        MDC.respring(useLegacyMethod: appState.useLegacyRespring)

                    }, label: {
                        Label("Respring", systemImage: "arrow.counterclockwise.circle")
                        Text("Respring")
                    })
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
