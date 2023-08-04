//
//  SettingsView.swift
//  ControlConfig
//
//  Created by f1shy-dev some time in the last 47 years.
//

import Foundation
import LocalConsole
import SwiftUI
import WelcomeSheet


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appState: AppState
    @ObservedObject var customisations: CustomisationList
    @State var showFirstLaunchSheet = false
    @State var showPrintActionsSheet = false
    @State var camlCALayer: CALayer?
    
    var puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048]
    var puaf_method_options = ["physpuppet", "smith"]
    var kread_method_options = ["kqueue_workloop_ctl", "sem_open"]
    var kwrite_method_options = ["dup", "sem_open"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Use old respring", isOn: $appState.useLegacyRespring)
                } header: {
                    Label("Respring", systemImage: "arrow.counterclockwise")
                } footer: {
                    Label("Only enable if respringing doesn't work.", systemImage: "info.circle")
                }

                Picker("SpringBoard Language", selection: $appState.sbRegionCode) {
                    ForEach(CCMappings.hardcodedRegions, id: \.self) { region in
                        Text(region).tag(region)
                    }
                }
                .pickerStyle(.automatic)
                .id(appState.sbRegionCode)
//                .onReceive(self.customisation.$mode) { _ in
//                    customisation.objectWillChange.send()
//                }

                Section {
                    Picker(selection: $appState.puaf_pages_index, label: Text("puaf pages:")) {
                                               ForEach(0 ..< puaf_pages_options.count, id: \.self) {
                                                   Text(String(self.puaf_pages_options[$0]))
                                               }
                                           }.disabled(kfd != 0)
                    
                    Picker(selection: $appState.puaf_method, label: Text("puaf method:")) {
                                             ForEach(0 ..< puaf_method_options.count, id: \.self) {
                                                 Text(self.puaf_method_options[$0])
                                             }
                                         }.disabled(kfd != 0)
                    
                    Picker(selection: $appState.kread_method, label: Text("kread method:")) {
                                               ForEach(0 ..< kread_method_options.count, id: \.self) {
                                                   Text(self.kread_method_options[$0])
                                               }
                                           }.disabled(kfd != 0)
                    
                    Picker(selection: $appState.kwrite_method, label: Text("kwrite method:")) {
                                               ForEach(0 ..< kwrite_method_options.count, id: \.self) {
                                                   Text(self.kwrite_method_options[$0])
                                               }
                                           }.disabled(kfd != 0)
                } header: {
                    Label("KFD Exploit Configuration", systemImage: "qrcode")
                } footer: {
                    Label("Only applies to 16.2 and above - requires restart of app to change/apply (ControlConfig runs kopen when you hit Apply for the first time) KFD State (0 means not kopen): \(kfd)", systemImage: "info.circle")
                }
                Section(header: Label("Debug", systemImage: "ladybug"), footer: Label("Settings meant for people who know what they're doing. Only touch anything here if the developers explicitly told you to.", systemImage: "info.circle")) {
                    Button("Export app logs") {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        if let encoded = try? encoder.encode(customisations.list) {
                            if customisations.list.isEmpty {
                                print("customisation list EMPTY")
                            } else {
                                print("customisation list")
                                print(String(data: encoded, encoding: .utf8)!)
                            }
                        }

                        print("""
                        Model Name:         \(SystemReport.shared.gestaltMarketingName)
                        Model Identifier:   \(SystemReport.shared.gestaltModelIdentifier)
                        Architecture:       \(SystemReport.shared.gestaltArchitecture)
                        Firmware:           \(SystemReport.shared.gestaltFirmwareVersion)
                        Kernel Version:     \(SystemReport.shared.kernel) \(SystemReport.shared.kernelVersion)
                        System Version:     \(SystemReport.shared.versionString)
                        OS Compile Date:    \(SystemReport.shared.compileDate)
                        Memory:             \(round(100 * Double(ProcessInfo.processInfo.physicalMemory) * pow(10, -9)) / 100) GB
                        Processor Cores:    \(Int(ProcessInfo.processInfo.processorCount))
                        """)
                        UIPasteboard.general.string = consoleManager.getCurrentText()
                        UIApplication.shared.confirmAlert(title: "Success", body: "Copied app logs to clipboard.", onOK: {}, noCancel: true)
                    }
                    Toggle("Enable debug mode", isOn: $appState.debugMode)
                    if appState.debugMode {
                        Toggle("Enable in-app console", isOn: $appState.enableConsole)
                        Toggle("Enable Experimental Features", isOn: $appState.enableExperimentalFeatures)
//                        Button("[WARNING] Better Compress Bundle IDs") {
//                            betterBundleIDCompressor()
//                        }
//                        Button("Enable hidden modules") {
//                            patchHiddenModules()
//                        }
                        Button("Trigger first-launch sheet") {
                            UserDefaults.standard.set(false, forKey: "shownFirstOpen")
                            showFirstLaunchSheet = true
                        }.welcomeSheet(isPresented: $showFirstLaunchSheet, onDismiss: {
                            UserDefaults.standard.set(true, forKey: "shownFirstOpen")
                        }, pages: firstLaunchSheetPages)
                        
                        Button("Show file-printing actions") {
                            showPrintActionsSheet = true
                        }.sheet(isPresented: $showPrintActionsSheet) {
                            List {
                                Button("Print module configuration m-ids (var)") {
                                    if let dict = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath), let currentList = dict["module-identifiers"] {
                                        print(currentList)
                                    }
                                }
                                
                                Button("Print module configuration (var)") {
                                        print(PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath))
                                }
                                
                                Button("Init some module with BID") {
                                    print(Module(bundleID: "com.apple.FocusUIModule")?.fileName)
                                }
                                
                                Button("Print module backup idx0") {
                                    print(BackupManager.shared.latestBackup?.modules)
                                }
                                
                                Button("Not added modules?") {
                                    let notAddedModules = fetchModules().filter { mod in
                                        !customisations.list.contains(where: {$0.module.fileName == mod.fileName})
                                    }.filter{mod in
                                        CCMappings().hiddenModulesToPatch.contains(mod.fileName)
                                    }
                                    print(notAddedModules.map {$0.fileName})
                                    
                                }
                                
                                Button("Latest backup path URL") {
                                    if let xd = BackupManager.shared.latestBackup?.folderPath {
                                        do {print(try FileManager.default.contentsOfDirectory(atPath: xd))}
                                        catch {print(error)}
                                    }
                                }
                                
                                
                                Button("Next level CAML padding bypass >w<") {
                                    let pl = PlistHelpers.plistToDict(path: "/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle/replaykit.ca/index.xml")
                                    print(pl)
                                }
                                
//                                Button("Print CAPackage of CAML") {
//                                    do {
//                                        let pack = try CAPackage(contentsOf: URL(fileURLWithPath: "/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle/replaykit.ca"), type: kCAPackageTypeCAMLBundle, options: nil)
//                                        camlCALayer = (pack as? CAPackage)?.rootLayer
//                                        print((pack as? CAPackage)?.rootLayer)
//                                        
//                                    }
//                                    catch {print(error)}
//                                }
                                
//                                if let ca = camlCALayer {
//                                    CALayerRenderer(layer: ca).frame(width: 48, height: 48)
//                                }
                            }
                        }
                    }
                }
                Section {} header: {
                    VStack {
                        Text("ControlConfig \(appVersion)\nMade with \(Image(systemName: "heart.fill")) by sneakyf1shy & BomberFish.")
                    }
                }.textCase(.none)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Close", systemImage: "xmark")
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("App Settings")
        }
    }
}
