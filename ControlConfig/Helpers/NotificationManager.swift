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

func sendNotification(title: String, subtitle: String, secondsLater: TimeInterval, isRepeating: Bool) {
    if (!AppState.shared.enableTipNotifications) { return }
    requestNotificationAuth { auth in
        if (!auth) { return }
        
        // Define the content
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsLater, repeats: isRepeating)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
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
