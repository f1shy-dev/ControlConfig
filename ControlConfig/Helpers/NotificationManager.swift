//
//
// NotificationManager.swift
// ControlConfig
//
// Created by f1shy-dev on 08/08/2023
//
        

import Foundation
import SwiftUI
import UserNotifications

func sendNotification(identifier: String, title: String, subtitle: String, secondsLater: TimeInterval, isRepeating: Bool) {
    if (!AppState.shared.enableTipNotifications) { return }

    requestNotificationAuth { auth in
        if (!auth) { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "\(subtitle)\n\nYou can hide these tips in app settings."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsLater, repeats: isRepeating)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("[notif] request added in \(secondsLater) seconds - \(title): \(subtitle)")
    }
}

func requestNotificationAuth(_ completionHandler: @escaping (Bool) -> Void = {_ in }){
    if (!AppState.shared.enableTipNotifications) { return }
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { success, error in
        if let error {
            print("Notification access not granted.", error.localizedDescription)
            completionHandler(false)
        } else {completionHandler(true)}
    }
}

class NotificationHandlerAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle the notification when the app is in the foreground
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get the identifier of the tapped notification
        let identifier = response.notification.request.identifier
        
        print("[notif] clicked on id: \(identifier)")
        
        // Handle different notifications based on their identifiers
        switch identifier {
        case "dont-see-modules":
            if activeExploit == .KFD {
                applyAndOpenReorder()
            } else {
                UIApplication.shared.alert(title:"How did we get here?", body: "You can only this on a kfd device/ios version...")
            }
        case "failed-hybrid":
            if let errorLog = UserDefaults.standard.value(forKey: "last-hybrid-failure-log") as? String {
                UIApplication.shared.alert(title: "⛔️ Hybrid Apply Error", body: errorLog)
            } else {
                UIApplication.shared.alert(title: "⛔️ Hybrid Apply Error", body: "An error occured while applying your modules and customisiations. Please adjust any relevant settings and try again, and if it still does not work then try rebooting your device. If it still does not work, please report this to the developer and provide any logs/details of what you tried. (Note: ControlConfig was unable to collect any details about the error.)")
                UserDefaults.standard.set(nil, forKey: "last-hybrid-failure-log")

            }
        default:
            break
        }
        
        // Call the completion handler when done
        completionHandler()
    }
}
