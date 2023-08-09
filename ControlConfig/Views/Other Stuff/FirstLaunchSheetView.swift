//
//  FirstLaunchSheetView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 13/03/2023
//

import SwiftUI
import WelcomeSheet

let firstLaunchSheetPages = [
    WelcomeSheetPage(title: "Welcome to ControlConfig", rows: [
        WelcomeSheetPageRow(imageSystemName: "paintbrush.fill",
                            title: "Customisations",
                            content: "Make modules do whatever you want, and look how you want them to - size, position, color."),

        WelcomeSheetPageRow(imageSystemName: "photo.on.rectangle.angled",
                            title: "Icons",
                            content: "Edit the icons for any module, using your own icons or community presets."),

        WelcomeSheetPageRow(imageSystemName: "ipad.and.iphone",
                            title: "Works on MDC and KFD",
                            content: "ControlConfig works on devices on iOS 15-16.5 and also 16.6b1.")
    ])
//    WelcomeSheetPage(title: "Beta Information", rows: [
//        WelcomeSheetPageRow(imageSystemName: "ladybug",
//                            title: "Bugs/Issues",
//                            content: "As ControlConfig is still in development, there are many issues. Report anything you experience to the developer."),
//
//        WelcomeSheetPageRow(imageSystemName: "exclamationmark.triangle",
//                            title: "Disabled Features",
//                            content: "Due to some issues, colors is disabled for now. This will be fixed soon."),
//
//        WelcomeSheetPageRow(imageSystemName: "checkmark.seal",
//                            title: "Enjoy!",
//                            content: "Feel free to do whatever, and showcase to others. More features coming soon.")
//    ])
]
