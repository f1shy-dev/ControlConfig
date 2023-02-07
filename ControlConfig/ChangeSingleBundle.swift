//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI

struct ChangeSingleBundleView: View {
    @State var ccModule = CCModule(fileName: "NFCControlCenterModule.bundle")
    @State var id = ""

    let ccModules = getCCModules()

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Bundle ID of App (to launch)", text: $id)

                    Picker("Module to Replace", selection: $ccModule) {
                        ForEach(ccModules) { module in
                            Text(module.description).tag(module.fileName)
                        }
                    }.pickerStyle(.menu)
                }
                Section {
                    Button(
                        action: {
                            let success = overwriteModule(appBundleID: id, module: ccModule)
                            if success {
                                UIApplication.shared.alert(title: "Success", body: "Successfully wrote to file!", withButton: true)

                                Haptic.shared.notify(.success)
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)

                                Haptic.shared.notify(.error)
                            }
                        },
                        label: {
                            Label("Hit it.", systemImage: "flag.checkered.2.crossed")
                        }
                    )
                }
            }
            .navigationTitle("ControlConfig")
            .toolbar {
                Button(action: {
                    respring()

                }, label: {
                    Label("Respring", systemImage: "arrow.counterclockwise.circle")
                    Text("Respring")

                })
            }
        }
    }
}

struct ChangeSingleBundleView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeSingleBundleView()
    }
}
