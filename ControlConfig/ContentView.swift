//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(
                        action: {
                            let success = overwriteMagnifierModule(bundleId: "com.apple.")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
