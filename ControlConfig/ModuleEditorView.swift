//
//  ModuleEditorView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import Combine
import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .green : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.bordered).clipShape(Capsule()).foregroundColor(.primary)
    }
}

struct CustomisationCard: View {
    @State var descString = ""
    @State var showingEditSheet = false
    @State var customisationList: CustomisationList
    @Binding var customisation: CCCustomisation

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Group {
                    Image(systemName: customisation.module.sfIcon)
                        .font(.title2)
                }.frame(width: 30)
                Spacer().frame(width: 10)
                VStack(alignment: .leading) {
                    Text(customisation.module.description)
                        .font(.title3)
                        .foregroundColor(.primary)

                    Text(customisation.description)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()

            }.padding([.horizontal, .top]).frame(maxWidth: .infinity)

            Spacer().frame(height: 10)
            HStack {
                Toggle("Enabled", isOn: $customisation.isEnabled).labelsHidden().toggleStyle(CheckToggleStyle())
                Spacer()
                Button(action: {
                    showingEditSheet.toggle()
                }) { Label("Edit", systemImage: "pencil") }.buttonStyle(.bordered).clipShape(Capsule())
                Button(action: {
                    customisationList.deleteCustomisation(item: customisation)
                }) { Label("Delete", systemImage: "trash").foregroundColor(.red) }.buttonStyle(.bordered).clipShape(Capsule())

            }.padding([.horizontal, .bottom]).frame(maxWidth: .infinity)
        }
        .background(.regularMaterial)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingEditSheet) {
            SingleModuleEditView(customisation: customisation)
        }
    }
}

struct SingleModuleEditView: View {
    @Environment(\.dismiss) var dismiss
    @State var customisation: CCCustomisation

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
                }.pickerStyle(.menu)

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

struct AddNewModuleView: View {
    @Environment(\.dismiss) var dismiss
    @State var customisations: CustomisationList

    var body: some View {
        let filteredModules = getCCModules().filter { module in
            if (customisations.list.contains { customisation in
                customisation.module == module
            }) { return false }
            return true
        }

        return NavigationView {
            Form {
                Section(header: Label("Default Modules", systemImage: "slider.horizontal.3")) {
                    ForEach(filteredModules.filter { m in
                        m.isDefaultModule
                    }) {
                        let module = $0
                        HStack {
                            Label(module.description, systemImage: module.sfIcon)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            customisations.addCustomisation(item: CCCustomisation(isEnabled: false, module: module, mode: .AppLauncher))
                            dismiss()
                        }
                    }
                }

                Section(header: Label("Movable Modules", systemImage: "slider.vertical.3")) {
                    ForEach(filteredModules.filter { m in
                        !m.isDefaultModule
                    }) {
                        let module = $0
                        HStack {
                            Label(module.description, systemImage: module.sfIcon)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            customisations.addCustomisation(item: CCCustomisation(isEnabled: false, module: module, mode: .AppLauncher))
                            dismiss()
                        }
                    }
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

struct ModuleEditorView: View {
//    @State var ccModule = CCModule(fileName: "NFCControlCenterModule.bundle")
//    @State var id = ""
    @State private var showingAddNewSheet = false
    @StateObject var customisations = CustomisationList.loadFromUserDefaults()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach($customisations.list, id: \.module.bundleID) { item in
                    CustomisationCard(customisationList: customisations, customisation: item)
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        Haptic.shared.play(.soft)
//                        let success = overwriteModule(appBundleID: id, module: ccModule)
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
                        respring()

                    }, label: {
                        Label("Respring", systemImage: "arrow.counterclockwise.circle")
                        Text("Respring")

                    })

                    Spacer()
                    Button(action: {
                        print("settings...")
                    }, label: {
                        Label("Add Module", systemImage: "gear")
                    })

                    Button(action: {
                        showingAddNewSheet.toggle()
                    }, label: {
                        Label("Add Module", systemImage: "plus.app")
                    }).sheet(isPresented: $showingAddNewSheet) {
                        AddNewModuleView(customisations: customisations)
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ModuleEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ModuleEditorView()
    }
}
