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
    @EnvironmentObject var appState: AppState
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
                    Toggle("Use legacy respring", isOn: $appState.useLegacyRespring)
                    Picker("SpringBoard Language", selection: $appState.sbRegionCode) {
                        ForEach(CCMappings.hardcodedRegions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                    .pickerStyle(.automatic)
                    .id(appState.sbRegionCode)
                    Toggle("Enable tip notifications", isOn: $appState.enableTipNotifications)
                } header: {
                    Label("General", systemImage: "gear")
                } footer: {
                    Label("Only enable legacy respring if frontboard/backboard respringing don't work.", systemImage: "info.circle")
                }


//                .onReceive(self.customisation.$mode) { _ in
//                    customisation.objectWillChange.send()
//                }

                if activeExploit == .KFD {
                    Section(header:Label("KFD Exploit Configuration", systemImage: "slider.horizontal.3"), footer:Label("ControlConfig runs kopen when you hit Apply for the first time\n\nKFD State (0 means not kopen): \(kfd)", systemImage: "info.circle")) {
                        Picker(selection: $appState.puaf_pages_index, label: Text("PUAF Pages")) {
                            ForEach(0 ..< puaf_pages_options.count, id: \.self) {
                                Text(String(self.puaf_pages_options[$0]))
                            }
                        }.disabled(kfd != 0)
                        
                        Picker(selection: $appState.puaf_method, label: Text("PUAF Method")) {
                            ForEach(0 ..< puaf_method_options.count, id: \.self) {
                                Text(self.puaf_method_options[$0])
                            }
                        }.disabled(kfd != 0)
                        
                        
                        Picker(selection: $appState.kread_method, label: Text("Read Method")) {
                            ForEach(0 ..< kread_method_options.count, id: \.self) {
                                Text(self.kread_method_options[$0])
                            }
                        }.disabled(kfd != 0)
                        
                        Picker(selection: $appState.kwrite_method, label: Text("Write Method")) {
                            ForEach(0 ..< kwrite_method_options.count, id: \.self) {
                                Text(self.kwrite_method_options[$0])
                            }
                        }.disabled(kfd != 0)
                        
                        Button {
                            appState.puaf_pages_index = 7
                            appState.puaf_method = 1
                            appState.kread_method = 1
                            appState.kwrite_method = 1
                        } label: {
                            Label("Reset to defaults", systemImage: "arrow.clockwise")
                        }

                        
                    }
                }
                
                if activeExploit == .KFD{
                    Section(header: Label("KFD Hybrid Apply", systemImage: "repeat"), footer:Label("Hybrid Apply overwrites files before and during the respring process multiple times, to improve the chance of your tweaks applying. Access it by holding down on Apply in the main screen.", systemImage: "info.circle")) {
                    
                        Stepper(value: $appState.hybrid_apply_pre_tries.doubleBinding, in: 0 ... 10, step: 1) {
                            Text("Applies Before Respring (\(appState.hybrid_apply_pre_tries))")
                        }
                    
                    
              
                        Stepper(value: $appState.hybrid_apply_after_tries.doubleBinding, in: 0 ... 10, step: 1) {
                            Text("Applies After Respring (\(appState.hybrid_apply_after_tries))")
                        }
                        
                        
                        Toggle("Kclose after hybrid apply", isOn: $appState.hybrid_apply_kclose_when_done)
                    }
                }
                Section(header: Label("Debug", systemImage: "ladybug")) {
                    Button("Export app logs") {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        if let encoded = try? encoder.encode(appState) {
                                print("[AppState JSON Encoded]")
                                print(String(data: encoded, encoding: .utf8)!)
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
//                        Toggle("Enable in-app console", isOn: $appState.enableConsole)
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

                        Button("Open debug actions menu") {
                            showPrintActionsSheet = true
                        }.sheet(isPresented: $showPrintActionsSheet) {
                           DebugActionsMenu()
                        }
                        
                        if #available(iOS 16.0, *) {
                            Toggle("⚠️ Force KFD Exploit", isOn: $appState.force_kfd_exploit)
                        }

                    }
                }
//                Section {} header: {
//                    VStack {
//                        Text("ControlConfig \(appVersion)\nMade with \(Image(systemName: "heart.fill")) by sneakyf1shy & BomberFish.")
//                    }
//                } footer: {
//                    Text("") // add an empty Text view as the footer parameter
//                }.textCase(.none)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
