//
//
// ApplyAndReorder.swift
// ControlConfig
//
// Created by f1shy-dev on 10/08/2023
//
        

import Foundation
import UIKit

func applyAndOpenReorder() {
    DispatchQueue.global(qos: .userInitiated).async {
        let success = applyChanges()
        DispatchQueue.main.async {
            if success.0 {
                Haptic.shared.notify(.success)
                xpc_crash("com.apple.Preferences")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let url = URL(string: "App-prefs:ControlCenter") {
                        UIApplication.shared.open(url)
                    }
                }
                sendNotification(identifier:"dont-see-modules", title: "Don't see your modules?", subtitle: "Tap to apply and try again.", secondsLater: 2, isRepeating: false)
            } else {
                Haptic.shared.notify(.error)
                let failed = success.1.filter { $0.value == false }.map { $0.key }.joined(separator: "\n")
                UIApplication.shared.alert(title: "⛔️ Error", body: "An error occured while applying your modules and customisiations. The write operations that failed are: \n\n\(failed)\n\nPlease adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried.")
            }
        }
    }
}
