//
//  FixedMappings.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import UIKit

public struct CCMappings {
    public static let bundlesPath = "/System/Library/ControlCenter/Bundles/"
    public static let privFrameworksPath = "/System/Library/PrivateFrameworks/"
    public var dmsPath: String {
        let dmsBase = CCMappings.privFrameworksPath + "ControlCenterUI.framework/DefaultModuleSettings~"
        if UIDevice.current.userInterfaceIdiom == .pad {
            return dmsBase + "ipad.plist"
        } else {
            return dmsBase + "iphone.plist"
        }
    }

    public static let bundleIDBasedModuleNameOverrides: NSDictionary = [
        "com.apple.shazamkit.controlcenter.ShazamModule": "Shazam",
        "com.apple.control-center.DisplayModule": "Brightness",
        "com.apple.mediaremote.controlcenter.nowplaying": "Media Player",
        "com.apple.Home.ControlCenter": "Home (large)",
        "com.apple.mediaremote.controlcenter.audio": "Volume"
        // TODO: mediacontrolsaudio, silencecallsccwidget and others
    ]

    public static let bundleIDBasedSFIcons: NSDictionary = [
        "com.apple.replaykit.VideoConferenceControlCenterModule": "video",
        "com.apple.FocusUIModule": "moon",
        "com.apple.Home.ControlCenter": "homekit",
        "com.apple.control-center.DisplayModule": "sun.max",
        "com.apple.mediaremote.controlcenter.audio": "speaker.wave.2",
        "com.apple.control-center.ConnectivityModule": "wifi",
        "com.apple.replaykit.AudioConferenceControlCenterModule": "mic",
        "com.apple.mediaremote.controlcenter.nowplaying": "waveform"
    ]
}
