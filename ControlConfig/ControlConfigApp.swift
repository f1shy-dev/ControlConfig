//
//  ControlConfigApp.swift
//  ControlConfig
//
//  Created by f1shy-dev on 2023-02-06.
//  Credits: Cowabunga, bomberfish
//

import LocalConsole
import SwiftUI
import WelcomeSheet

let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
let consoleManager = LCManager.shared
let isiOSSixteen = ProcessInfo().operatingSystemVersion.majorVersion == 16

enum PatchStage {
    case Detecting, NoMDCSupported, UnableToEscape(err: String), TooOld, Escaped
}

struct BareLoading: View {
    var icon: String
    var title: String
    var msg: String
    var animateRotate: Bool
    @State private var rotationAngle: Double = 0
    init(icon: String = "gear", animateRotate: Bool = false, title: String, msg: String) {
        self.icon = icon
        self.title = title
        self.msg = msg
        self.animateRotate = animateRotate
    }

    var body: some View {
        if animateRotate {
            Image(systemName: icon).font(.system(size: 38)).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)).foregroundColor(.accentColor)
                .rotationEffect(.degrees(rotationAngle))
            .animation(
                Animation.linear(duration: 4).repeatForever(autoreverses: false)
            ).onAppear {
                rotationAngle += 360
            }
        } else {
            Image(systemName: icon).font(.system(size: 38)).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)).foregroundColor(.accentColor)
        }
        Text(title).font(.system(size: 24, weight: .semibold))
        Text(.init(msg)).foregroundColor(Color(UIColor.secondaryLabel)).multilineTextAlignment(.center).padding(EdgeInsets(top: 1, leading: 16, bottom: 12, trailing: 16))
    }
}


@main
struct ControlConfigApp: App {
    @State var showingBackupSheet = false
    @State var showingFirstLaunchSheet = false
    @State var backupStage: BackupStage = .YetToRespring
    @State var localPatchState: PatchStage = .Detecting
    @State private var rotationAngle: Double = 0

    var body: some Scene {
        WindowGroup {
            ZStack{
                VStack(alignment: .center) {
                    switch localPatchState {
                    case .Detecting:
                        BareLoading(animateRotate: true, title: "Patching", msg: "Please wait patiently, this can take a second. Also, please accept any access popups...")
                    case .NoMDCSupported:
                        BareLoading(icon:"exclamationmark.triangle.fill",title: "Not Supported", msg: "ControlConfig only works on iOS versions 15 to 16.1.2 and iOS 16.2 Developer Beta 1.")
                    case .UnableToEscape(let err):
                        BareLoading(icon:"exclamationmark.triangle.fill",title: "MDC Access Error", msg: "There was an error while trying to gain full disk access. Please close the app and retry. Error message: \(err)")
                    case .TooOld:
                        BareLoading(icon:"exclamationmark.triangle.fill",title: "Not Supported", msg: "ControlConfig only works on iOS versions 15 to 16.1.2 and iOS 16.2 Developer Beta 1. You may have some success if you install the app with TrollStore, but this isn't recommended.")
                    case .Escaped:
                        MainModuleView().transition(.opacity).onAppear {
                            #if targetEnvironment(simulator)
                            #else
                            BackupManager.shared.loadBackupList()
                            if BackupManager.shared.backups.count == 0 {
                                Thread.sleep(forTimeInterval: 0.05)
                                print("❓ Reloading backup list to be sure...")
                                BackupManager.shared.loadBackupList()
                            }
                            
                            let isDoingBk = UserDefaults.standard.bool(forKey: "isCurrentlyDoingBackup")
                            if BackupManager.shared.backups.count == 0 || isDoingBk {
                                backupStage = .YetToRespring
                                if isDoingBk { backupStage = .BackupLoading }
                                showingBackupSheet = true
                            } else {
                                if !UserDefaults.standard.bool(forKey: "shownFirstOpen") {
                                    showingFirstLaunchSheet = true
                                }
                            }
                            #endif
                            
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/f1shy-dev/ControlConfig/releases/latest") {
                                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else { return }

                                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                        if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                            print("Update found: \(appVersion) -> \(json["tag_name"] ?? "null")")
                                            UIApplication.shared.confirmAlert(title: "Update available!", body: "A new app update is available, do you want to visit the releases page?", onOK: {
                                                UIApplication.shared.open(URL(string: "https://github.com/f1shy-dev/ControlConfig/releases/latest")!)
                                            }, noCancel: false)
                                        }
                                    }
                                }
                                task.resume()
                            }
                        }
                                
                    }
                }
            }
            .sheet(isPresented: $showingBackupSheet) {
                    BackupView(backupStage: $backupStage)
                }
                .welcomeSheet(isPresented: $showingFirstLaunchSheet, onDismiss: {
                    UserDefaults.standard.set(true, forKey: "shownFirstOpen")
                }, isSlideToDismissDisabled: true, preferredColorScheme: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light, pages: firstLaunchSheetPages)
                .onAppear {
                   
                    let appVersion = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown") + ")")
                    print("🚀 ControlConfig - v\(appVersion)")
                    #if targetEnvironment(simulator)
                    localPatchState = .Escaped
                    #else
                    if #available(iOS 16.3, *) {
                        print("⛔️ iOS 16.3 or higher - MDC not supported")
                        localPatchState = .NoMDCSupported
                    } else {
                        if UIDevice.current.systemVersion == "16.2" {
                            let largeVer = ProcessInfo.processInfo.operatingSystemVersionString
                            let splitted = largeVer.components(separatedBy: ["(", " ", ")"])
                            if splitted.count >= 4,
                               !["20C5032e", "20C5043e"].contains(splitted[4]) {
                                print("⛔️ iOS 16.2 or higher (no dev build 1/2?) - MDC not supported")
                                localPatchState = .NoMDCSupported
                                return
                            }
                        }
                        DispatchQueue.global(qos: .userInitiated).async {
                            do {
                                try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                                print("⚙️ TrollStore install detected...")
                                DispatchQueue.main.async {
                                    withAnimation {
                                        localPatchState = .Escaped
                                    }
                                }
                            } catch {
                                localPatchState = .Detecting
                                if #available(iOS 15, *) {
                                    print("⚙️ Running MDC exploit...")
                                    grant_full_disk_access { error in
                                        if error != nil {
                                            print("⛔️ Unable to escape sandbox! - ", String(describing: error?.localizedDescription ?? "unknown?!"))
                                            localPatchState = .UnableToEscape(err: String(describing: error?.localizedDescription))
                                        } else {
                                            DispatchQueue.main.async {
                                                withAnimation {
                                                    localPatchState = .Escaped
                                                }
                                            }
                                            print("✅ Successfully escaped sandbox with MDC!")
                                        }
                                    }
                                } else {
                                    print("⛔️ iOS older than 15 - not supported.")
                                    localPatchState = .TooOld
                                }
                            }
                        }
                    }
                    #endif

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
