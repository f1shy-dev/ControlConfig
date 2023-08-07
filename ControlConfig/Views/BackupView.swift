//
//  BackupView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 10/03/2023
//

import LocalConsole
import SwiftUI

let baseMsg = "When you click the button below, your device will respring, after which you **must re-open the app** and wait a few seconds, after which you can use the app normally. Please **remove/disable any other customisations** you may have applied to the control center before starting."

enum BackupStage {
    case YetToRespring, BackupLoading, BackupDone, BackupFailed
}

struct BackupBareView<Content: View>: View {
    var icon: String
    var title: String
    var msg: String
    let content: Content

    init(icon: String = "folder.badge.gearshape", title: String, msg: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.msg = msg
        self.content = content()
    }

    var body: some View {
        Image(systemName: icon).font(.system(size: 38)).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)).foregroundColor(.accentColor)
        Text(title).font(.system(size: 24, weight: .semibold))
        Text(.init(msg)).foregroundColor(Color(UIColor.secondaryLabel)).multilineTextAlignment(.center).padding(EdgeInsets(top: 1, leading: 0, bottom: 12, trailing: 0))
        self.content.buttonStyle(.bordered)
    }
}

struct BackupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var backupStage: BackupStage
    let forcedBackup: Bool = false
    var body: some View {
        let _ = print("state", backupStage == .YetToRespring, backupStage == .BackupLoading, UserDefaults.standard.bool(forKey: "isCurrentlyDoingBackup"))
//        let msgBase: String = forcedBackup ? "Before being able to use the app, ControlConfig needs to take a backup of your control center configuration. " : ""
        VStack {
            switch backupStage {
            case .YetToRespring:
                BackupBareView(title: "CC Backup Required", msg: "Before being able to use the app, ControlConfig needs to take a backup of your control center configuration. " + baseMsg) {
                    Button("Start Backup") {
                        UserDefaults.standard.set(true, forKey: "isCurrentlyDoingBackup")
//                        MDC.respring(method: .backboard)
                        backupStage = .BackupLoading
                        DispatchQueue.global(qos: .userInitiated).async {
                            let result = BackupManager.shared.createBackup()
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(false, forKey: "isCurrentlyDoingBackup")
                                backupStage = .BackupDone
                            }
                        }
                    }
                }
            case .BackupLoading:
                BackupBareView(title: "CC Backup", msg: "ControlConfig is backing up your control center configuration. Please be patient, this can take upto 30 seconds...") {
                    ProgressView().onAppear {
                        backupStage = .BackupLoading
                        DispatchQueue.global(qos: .userInitiated).async {
                            let result = BackupManager.shared.createBackup()
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(false, forKey: "isCurrentlyDoingBackup")
                                backupStage = .BackupDone
                            }
                        }
                    }
                }
            case .BackupDone:
                BackupBareView(icon: "checkmark.circle", title: "Backup Completed", msg: "The backup was successful. You can now use the app!") {
                    Button("Close") {
                        UserDefaults.standard.set(false, forKey: "isCurrentlyDoingBackup")
                        dismiss()
                    }
                }
            case .BackupFailed:
                BackupBareView(icon: "exclamationmark.triangle", title: "Backup Failed", msg: "There was an issue while trying to take a backup, please report this to the developers and re-launch the app and try again.") {
                    HStack {
                        Button("Copy Debug Log") {
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
                    }
                }
            }

        }.interactiveDismissDisabled(true).padding([.horizontal])
    }
}

// struct BackupView_Previews: PreviewProvider {
//    static var previews: some View {
//        BackupView(backupStage: )
//            .padding()
//    }
// }
