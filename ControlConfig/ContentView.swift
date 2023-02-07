//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI

struct ContentView: View {
    @State var module = "MagnifierModule"
    @State var id = "com.apple.Magnifier"
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Bundle ID: ", text: $id)
                } header: {
                    Label("Bundle", systemImage: "shippingbox")
                }
                Section {
                    TextField("Module", text: $module)
                } header: {
                    Label("Module ID", systemImage: "shippingbox")
                }
                Section {
                    Button(
                        action: {
                            let success = overwriteModule(bundleVal: id, moduleName: module)
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
                Button(action:{
                    respring()
                    
                }, label:{
                    Label("Respring", systemImage: "arrow.counterclockwise.circle")
                    Text("Respring")
                    
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
