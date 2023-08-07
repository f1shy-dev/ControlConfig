//
//  AddModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI

struct AddModuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var customisations: CustomisationList

    var body: some View {
        let filteredModules = fetchModules().filter { module in
            if (customisations.list.contains { customisation in
                customisation.module.fileName == module.fileName
            }) { return false }
            return true
        }

        return NavigationView {
            Form {
//                Section(header: Label("Default Modules", systemImage: "slider.horizontal.3")) {
//                    ForEach(filteredModules.filter { m in
//                        m.isDefaultModule
//                    }) {
//                        let module = $0
//                        HStack {
//                            Label(module.description, systemImage: module.sfIcon)
//                            Spacer()
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            customisations.addCustomisation(item: Customisation(module: module))
//                            dismiss()
//                        }
//                    }
//                }

//                Section(header: Label("Movable Modules", systemImage: "slider.vertical.3")) {
                ForEach(filteredModules.sorted(by: { $0.description < $1.description })) {
                    let module = $0
                    HStack {
//                        Label(module.description, systemImage: module.sfIcon)
                        Label(title: {
                            VStack(alignment: .leading, spacing:0){
                                Text(module.description)
                                if module.fileName == "ContinuousExposeModule.bundle" {
                                    Text("Note: This module is known to cause respring issues on device rotation when Stage Manager is turned on an unsupported device.")
                                        .font(.system(.caption))
                                        .foregroundColor(.gray)
                                        .padding(.top, 0.6)
                                }
                            }
                        }, icon: {
                            Image(systemName: module.sfIcon)
                        })
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        customisations.addCustomisation(item: Customisation(module: module))
                        dismiss()
                    }
//                    }
                }
            }
            .navigationTitle("New customisation")
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

// TODO: Previews?
