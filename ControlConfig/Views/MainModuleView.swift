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
    @ObservedObject var appState = AppState.shared
    @State private var test = Color(.gray)

    var body: some View {
        NavigationView {
            VStack {
                if customisations.list.isEmpty {
//                    Spacer().frame(height: CGFloat(UIScreen.main.bounds.size.height / 3) - 100)
                    Spacer()
                    VStack {
                        Image(systemName: "questionmark.app.dashed")
                            .font(.system(size: 60, weight: .light))
                            .padding(.vertical, -8)
                        Text("No Modules")
                            .font(.system(size: 30, weight: .semibold))
                        Text("Press the \(Image(systemName: "plus.app")) button below to add one!")
                            .font(.system(size: 15))
                    }
                    .padding()
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                } else {
                    // scrollview (.vertical)
                    List {
//                        List {
                        Section(header: Label("Options", systemImage: "paintbrush")) {
                            ColorPicker("Module Colour", selection: $test)
                        }

//                        }
                        Section(header: Label("Customisations", systemImage: "app.dashed")) {
                            ForEach(customisations.list, id: \.module.bundleID) { item in

                                CustomisationCard(customisation: item, appState: appState, deleteCustomisation: customisations.deleteCustomisation, saveToUserDefaults: customisations.saveToUserDefaults) {
                                    customisations.objectWillChange.send()
                                }
                                //                            .listRowSeparator(.hidden)

                                //                            .listRowBackground(RoundedRectangle(cornerRadius: 10).foregroundColor(.black))
                            }
                        }
//                        Form {
//                            Section(header: Label("Options", systemImage: "pencil")) {
//                                Button("What about here?") {
//                                    print("Hello world")
//                                }
//                            }
//                        }
//
//                        Button("What about here?") {
//                            print("Hello world")
//                        }
//                        .buttonStyle(.bordered)
                    }
                    .listRowInsets(.none)
//                    .listStyle(.insetGrouped)
//                        .padding(EdgeInsets(top: 44, leading: 0, bottom: 24, trailing: 0))
//                    .edgesIgnoringSafeArea(.all)
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
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
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        print(customisations)
                        let success = applyChanges(customisations: customisations)
                        if success {
                            Haptic.shared.notify(.success)
                            UIApplication.shared.confirmAlert(title: "Applied!", body: "Please respring to see any changes.", onOK: {}, noCancel: true)
                        } else {
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(body: "An error occurred when writing to the file(s). This might be due to custom width/heights, which might have made the file too large. Please try and re-arrange your custom width/heights first, and then try again, and if not, please report this to the developer.")
                        }
                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    })
                    .disabled(customisations.list.filter { c in c.isEnabled }.isEmpty)

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
