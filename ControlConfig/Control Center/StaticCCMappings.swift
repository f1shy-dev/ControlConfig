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
    public static let moduleMaterialRecipePath = "/System/Library/PrivateFrameworks/CoreMaterial.framework/modules.materialrecipe"
    public static let moduleBackgroundMaterialRecipePath = "/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe"

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
        "com.apple.Home.CompactControlCenter": "Home (small)",
        "com.apple.FocusUIModule": "Focus",
        "com.apple.control-center.OrientationLockModule": "Orientation Lock",
        "com.apple.mediaremote.controlcenter.audio": "Volume",
        "com.apple.replaykit.controlcenter.screencapture": "Screen Recording",
        "com.apple.TelephonyUtilities.SilenceCallsCCWidget": "Silence Calls",
        "com.apple.control-center.AppleTVRemoteModule": "TV Remote",
        "com.apple.control-center.PerformanceTraceModule": "Performance Tracer",
        "com.apple.springboard.ContinuousExposeModule": "Stage Manager",
        // TODO: mediacontrolsaudio and others
    ]

    public var bundleIDBasedSFIcons: NSDictionary {
        var base = [
            "com.apple.replaykit.VideoConferenceControlCenterModule": "video",
            "com.apple.FocusUIModule": "moon.fill",
            "com.apple.Home.ControlCenter": "homekit",
            "com.apple.Home.CompactControlCenter": "homekit",
            "com.apple.control-center.DisplayModule": "sun.max",
            "com.apple.control-center.OrientationLockModule": "lock.rotation",
            "com.apple.mediaremote.controlcenter.audio": "speaker.wave.2",
            "com.apple.control-center.ConnectivityModule": "wifi",
            "com.apple.control-center.MuteModule": "bell.slash.fill",
            "com.apple.control-center.QuickNoteModule": "note.text",
            "com.apple.mobilenotes.SystemPaperControlCenterModule": "note.text",
            "com.apple.springboard.ContinuousExposeModule": "squares.leading.rectangle",
            "com.apple.control-center.FlashlightModule": "flashlight.off.fill",
            "com.apple.control-center.CameraModule": "camera.fill",
            "com.apple.control-center.LowPowerModule": "battery.25",

            "com.apple.shazamkit.controlcenter.ShazamModule": "shazam.logo.fill",
            // for lack of a better symbol
            "com.apple.TelephonyUtilities.SilenceCallsCCWidget": "iphone.homebutton.slash",
            "com.apple.replaykit.controlcenter.screencapture": "record.circle",
            "com.apple.replaykit.AudioConferenceControlCenterModule": "mic",
            "com.apple.control-center.AppleTVRemoteModule": "appletvremote.gen4.fill",
            "com.apple.control-center.FeedbackAssistanceModule": "exclamationmark.bubble.fill",
            "com.apple.control-center.PerformanceTraceModule": "waveform.path.ecg",
            "com.apple.mediaremote.controlcenter.nowplaying": "waveform",
            // TODO: more.
        ]

        if #available(iOS 16.0, *) {} else {
            base["com.apple.shazamkit.controlcenter.ShazamModule"] = "music.note.list"
        }
        return base as NSDictionary
    }
}
