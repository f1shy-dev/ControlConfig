//
//  ControlConfigApp.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//  Credits: cowabunga
//

import LocalConsole
import SwiftUI
import WelcomeSheet
import MacDirtyCow

var isUnsandboxed = false
let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
let consoleManager = LCManager.shared
let isiOSSixteen = ProcessInfo().operatingSystemVersion.majorVersion == 16

@main
struct ControlConfigApp: App {
    @State var showingBackupSheet = false
    @State var showingFirstLaunchSheet = false
    @State var backupStage: BackupStage = .YetToRespring
    var body: some Scene {
        WindowGroup {
//            TabView {
//                MainModuleView()
//                    .tabItem {
//                        Label("Customisations", systemImage: "square.grid.3x3.square")
//                    }
//
//                MainModuleView()
//                    .tabItem {
//                        Label("Options", systemImage: "paintbrush")
//                    }
//
            ////                OrderView()
            ////                    .tabItem {
            ////                        Label("Order", systemImage: "square.and.pencil")
            ////                    }
//            }
            MainModuleView()
                .sheet(isPresented: $showingBackupSheet) {
                    BackupView(backupStage: $backupStage)
                }
                .welcomeSheet(isPresented: $showingFirstLaunchSheet, onDismiss: {
                    UserDefaults.standard.set(true, forKey: "shownFirstOpen")
                }, isSlideToDismissDisabled: true, preferredColorScheme: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light, pages: firstLaunchSheetPages)
                .onAppear {
                    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
                    print("ControlConfig version \(appVersion)")
                    if #available(iOS 16.3, *) {
                        #if targetEnvironment(simulator)
                        #else
                        print("Throwing not supported error (mdc patched)")
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
                        #endif
                    } else {
                        do {
                            // TrollStore method
                            print("Checking if installed with TrollStore...")
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                            print("99% probably installed with TrollStore")
                            isUnsandboxed = true
                        } catch {
                            isUnsandboxed = false
                            print("Trying MDC method...")
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                print("Escaping Sandbox...")
                                // asyncAfter(deadline: .now())
                                DispatchQueue.global(qos: .userInitiated).sync {
                                    do {
                                        try MacDirtyCow.unsandbox()
                                        isUnsandboxed = true
                                    } catch {
                                        isUnsandboxed = false
                                        UIApplication.shared.alert(body: "Unsandboxing Error: \(error.localizedDescription)\nPlease close the app and retry.", withButton: false)
                                    }
                                }
                            } else {
                                print("Throwing not supported error (too old?!)")
                                UIApplication.shared.alert(title: "Exploit Not Supported", body: "Please install via TrollStore")
                                isUnsandboxed = false
                            }
                        }
                    }
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/BomberFish/ControlConfig/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                            guard let data = data else { return }

                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    print("Update found: \(appVersion) -> \(json["tag_name"] ?? "null")")
                                    UIApplication.shared.confirmAlert(title: "Update available!", body: "A new app update is available, do you want to visit the releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/BomberFish/ControlConfig/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }

                    // idk man
                    while !isUnsandboxed {
                        Thread.sleep(forTimeInterval: 0.1)
                    }

//                    BackupManager.shared.loadBackupList()
                    let isDoingBk = UserDefaults.standard.bool(forKey: "isCurrentlyDoingBackup")
                    if BackupManager.shared.backups.count == 0 || isDoingBk {
                        backupStage = .YetToRespring
                        if isDoingBk { backupStage = .BackupLoading }
                        showingBackupSheet = true
                    } else {
                        //                    Haptic.shared.notify(.success)
                        if !UserDefaults.standard.bool(forKey: "shownFirstOpen") {
//                            UIApplication.shared.alert(title: "Please read", body: "This app is still in alpha. Some features will not work. Please report any issues you run into to the developer, with logs exported from the settings menu.")
                            showingFirstLaunchSheet = true
                        }
                    }
                }
                .onOpenURL { url in

                    if let host = url.host,
                       let components = URLComponents(
                           url: url,
                           resolvingAgainstBaseURL: false
                       )
                    {
                        let path = url.path

                        // controlconfig://respring(?type=[backboard|frontboard|legacy])
                        if host == "respring" {
                            // Extract any parameters from the URL query string
                            let params = components.queryItems

                            if let typeParam = params?.first(where: { $0.name == "type" })?.value {
                                print("Respring action triggered with type parameter: \(typeParam)")
                                switch typeParam {
                                case "backboard":
                                    MDC.respring(method: .backboard)
                                case "legacy":
                                    MDC.respring(method: .legacy)
                                default:
                                    MDC.respring(method: .frontboard)
                                }

                            } else {
                                // TODO: make appstate shared structure
                                print("Respring action triggered!")
                                MDC.respring(method: AppState.shared.useLegacyRespring ? .legacy : .frontboard)
                            }
                        }
                    }
                }
        }
    }
}
