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
                            content: "Make modules in the control center do whatever you want, from opening apps to respringing."),

        WelcomeSheetPageRow(imageSystemName: "slider.horizontal.3",
                            title: "Sizing and Movement",
                            content: "Change the size of any module, and move all modules, without any empty spaces."),

        WelcomeSheetPageRow(imageSystemName: "ipad.and.iphone",
                            title: "Works on all MDC devices",
                            content: "ControlConfig works on any MDC-supported device, TrollStore devices and jailbroken devices (not 100%).")
    ]),
    WelcomeSheetPage(title: "Beta Information", rows: [
        WelcomeSheetPageRow(imageSystemName: "ladybug",
                            title: "Bugs/Issues",
                            content: "As ControlConfig is still in development, there are many issues. Report anything you experience to the developer."),

        WelcomeSheetPageRow(imageSystemName: "exclamationmark.triangle",
                            title: "Disabled Features",
                            content: "Due to some issues, colors is disabled for now. This will be fixed soon."),

        WelcomeSheetPageRow(imageSystemName: "checkmark.seal",
                            title: "Enjoy!",
                            content: "Feel free to do whatever, and showcase to others. More features coming soon.")
    ])
]
