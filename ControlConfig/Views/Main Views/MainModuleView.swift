//
//  MainModuleView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI
import WelcomeSheet

struct MainModuleView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingFirstLaunchSheet = true
    @State private var showingAddNewSheet = false
    @State private var showingSettingsSheet = false
    @State private var showingTutorialSheet = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        NavigationLink {
                            EditCCColorsView()
                        } label: {
                            Label("Edit CC Colours", systemImage: "paintbrush")
                        }

                        if appState.enableExperimentalFeatures {
                            NavigationLink {
                                AllIconsEditorView()
                            } label: {
                                Label("CC Icons Editor", systemImage: "paintbrush")
                            }
                            
                            NavigationLink {
                                ExploreView()
                            } label: {
                                Label("Explore", systemImage: "safari")
                            }
                            
                            NavigationLink{
                                CAMLEditorView(caFolderPath: "/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle/replaykit.ca")
                            } label: {
                                Label("CAML Editor - ReplayKit", systemImage: "pencil")
                            }
                        }
                        if activeExploit == .KFD {
                            Button {
                                applyAndOpenReorder()
                            } label: {
                                Label("Apply and open reorder menu", systemImage:"link")
                            }
                            Button(role: .destructive) {
                                if (kfd == 0) {
                                    return UIApplication.shared.alert(title: "KFD Exploit", body: "You can only use this button once you've clicked apply.", animated: true)
                                }
                                do_kclose()
                                exit(1)
                            } label: {
                                Label("Unpatch (kclose) and exit", systemImage:"arrow.down.right.and.arrow.up.left").foregroundColor(.red)
                            }
                        }
                    }

                    Section(header: HStack {
                            Text(activeExploit == .MDC ? "Modules" : "Customisations")
                            Spacer()
                            Button {
                                showingTutorialSheet.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                            }.sheet(isPresented: $showingTutorialSheet) {
                                TutorialSheetView()
                            }
                        
                        }, footer: Text(appState.currentSet.list.isEmpty ? "You don't have any \(activeExploit == .MDC ? "control center modules" : "customisations") yet - press the \(Image(systemName: "plus.app")) button below to add one!\n\nNot sure what to do? Check out the tutorial (press the \(Image(systemName: "info.circle")) button)": "")
                            ){
                            ForEach(appState.currentSet.list, id: \.module.bundleID) { item in

                                CustomisationCard(customisation: item, deleteCustomisation: {item in
                                    appState.currentSet.list.removeAll(where: {$0.module.fileName == item.module.fileName})
                                }).moveDisabled(activeExploit == .KFD)
                            }.onMove { from, to in
                                if activeExploit == .MDC {
                                    appState.currentSet.list.move(fromOffsets: from, toOffset: to)
                                }
                            }
                            .onDelete { idxset in
                                withAnimation {
                                    appState.currentSet.list.remove(atOffsets: idxset)
                                }
                            }
                        }.headerProminence(.increased)
                    
                }
                .listRowInsets(.none)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettingsSheet.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    }).sheet(isPresented: $showingSettingsSheet, onDismiss: {
                        appState.saveToDisk()
                    }) {
                        SettingsView()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if activeExploit == .MDC {
                        EditButton()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let success = applyChanges()
                            DispatchQueue.main.async {
                                if success.0 {
                                    let smsg = success.1.count == 0 ? "Everything's already applied (nothing changed on disk)." : "\(success.1.count) operation\(success.1.count < 2 ? "": "s") were completed successfully."
                                    Haptic.shared.notify(.success)
                                    UIApplication.shared.confirmAlert(title: "✅ Success", body: "\(smsg) Please respring to see any changes.", onOK: {}, noCancel: true)
                                } else {
                                    Haptic.shared.notify(.error)
                                    let failed = success.1.filter { $0.value == false }.map { $0.key }.joined(separator: "\n")
                                    UIApplication.shared.alert(title: "⛔️ Error", body: "An error occured while applying your modules and customisiations. The write operations that failed are: \n\n\(failed)\n\nPlease adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried.")
                                }
                            }
                        }

                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    }).contextMenu {
                        if activeExploit == .KFD {
                            Button("Run Exploit (kopen)") {
                                if kfd != 0 {
                                    return UIApplication.shared.alert(body: "Exploit has already been ran this session - kclose and relaunch app to run it again.")
                                }
                                let puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048]
                                let puaf_pages = puaf_pages_options[appState.puaf_pages_index]
                                print("puaf_pages: \(puaf_pages)")
                                kfd = do_kopen(UInt64(puaf_pages), UInt64(appState.puaf_method), UInt64(appState.kread_method), UInt64(appState.kwrite_method))
                                if kfd != 0 {
                                    do_fun()
                                }
                            }.disabled(kfd != 0)
                            Button("Hybrid Apply") {
                                var applies:[Bool] = []
                                var lastApply: [String:Bool] = [:]
                                for _ in 1...appState.hybrid_apply_pre_tries {
                                    let res = applyChanges()
                                    applies.append(res.0)
                                    lastApply = res.1
                                }
                                if applies.contains(where: {$0 == false}) {
                                    Haptic.shared.notify(.error)
                                    let failed = lastApply.filter { $0.value == false }.map { $0.key }.joined(separator: "\n")
                                    UIApplication.shared.alert(title: "⛔️ Error", body: "An error occured while applying your modules and customisiations. The write operations that failed are: \n\n\(failed)\n\nPlease adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried.")
                                } else {
                                    MDC.respring(method: .frontboard)
                                    for _ in 1...appState.hybrid_apply_after_tries {
                                        applies.append(applyChanges().0)
                                    }
                                    if applies.allSatisfy({$0 == true}) {
                                        sendNotification(identifier: "success-hybrid",title: "✅ Applied \(appState.hybrid_apply_pre_tries)+\(appState.hybrid_apply_after_tries) times - Didn't work?", subtitle: "Come back and hit apply again.", secondsLater: 1, isRepeating: false)
                                        if appState.hybrid_apply_kclose_when_done {
                                            do_kclose()
                                            exit(1)
                                        }
                                    } else {
                                        let failed = lastApply.filter { $0.value == false }.map { $0.key }.joined(separator: "\n")
                                        UserDefaults.standard.set("An error occured while applying your modules and customisiations using Hybrid Apply (failed after respring). The write operations that failed are: \n\n\(failed)\n\nPlease adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried.", forKey: "last-hybrid-failure-log")
                                        sendNotification(identifier: "failed-hybrid",title: "⛔️ Failed to apply!", subtitle: "Tap for more info...", secondsLater: 1, isRepeating: false)
                                    }

                                }
                            }
                        }
                    }


                    Spacer()

                    Button(action: {
                        Haptic.shared.play(.light)
                        showingAddNewSheet.toggle()
                    }, label: {
                        Label("Add Module", systemImage: "plus.app")

                    }).sheet(isPresented: $showingAddNewSheet) {
                        AddModuleView()
                    }

                    Spacer()

                    Button(action: {
                        MDC.respring(method: appState.useLegacyRespring ? .legacy : .frontboard)
                        if activeExploit == .KFD {
                            do_kclose()
                        }
                    }, label: {
                        Label("Respring", systemImage: "arrow.triangle.2.circlepath.circle")
                        Text("Respring")
                    }).contextMenu {
                        
                        Button {
                            MDC.respring(method: .frontboard)
                            do_kclose()
                        } label: {
                            Label("Frontboard Respring", systemImage: "arrow.triangle.2.circlepath")
                        }

                        Button {
                            MDC.respring(method: .backboard)
                        } label: {
                            Label("Backboard Respring", systemImage: "arrow.2.squarepath")
                        }
                        
                        Button {
                            MDC.respring(method: .legacy)
                        } label: {
                            Label("Legacy Respring", systemImage: "arrow.rectanglepath")
                        }
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
