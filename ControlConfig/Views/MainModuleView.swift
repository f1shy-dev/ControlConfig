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
    @ObservedObject var customisations = CustomisationList.loadFromUserDefaults()

    var body: some View {
        let _ = print("redrawing home editor view")

        NavigationView {
            ScrollView(.vertical) {
                ForEach(customisations.list, id: \.module.bundleID) { item in
                    CustomisationCard(customisation: item, deleteCustomisation: customisations.deleteCustomisation, saveToUserDefaults: customisations.saveToUserDefaults)
                }
                if customisations.list.isEmpty {
                    VStack {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 55))
                        Spacer()
                        Text("No Modules")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                        Spacer()
                        HStack {
                            Text("Press the")
                            Image(systemName: "plus.app")
                            Text("button to add one!")
                        }
                    }.padding()
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        applyChanges(customisations: customisations)
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
//                        consoleManager.isVisible.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    })

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
