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
    public static let moduleMaterialRecipePath =
        "\(privFrameworksPath)/CoreMaterial.framework/modules.materialrecipe"
    public static let moduleBackgroundMaterialRecipePath =
        "\(privFrameworksPath)/CoreMaterial.framework/modulesBackground.materialrecipe"
    public static let moduleConfigurationPath =
        "/var/mobile/Library/ControlCenter/ModuleConfiguration.plist"
    public static let moduleConfiguration_ccsupportPath =
        "/var/mobile/Library/ControlCenter/ModuleConfiguration_CCSupport.plist"
    public static let moduleAllowedListPath =
        "\(privFrameworksPath)/ControlCenterServices.framework/ModuleAllowedList.plist"

    public var dmsPath: String {
        let dmsBase = CCMappings.privFrameworksPath + "ControlCenterUI.framework/DefaultModuleSettings~"
        if UIDevice.current.userInterfaceIdiom == .pad {
            return dmsBase + "ipad.plist"
        } else {
            return dmsBase + "iphone.plist"
        }
    }

    public static let removalPlistValues: [String] = [
        "DTPlatformBuild",
        "DTSDKBuild",
        "DTXcodeBuild",
        "DTCompiler",
        "DTSDKName",
        "DTXcode",
        "BuildMachineOSBuild",
        "0",
        "MdC",
        "$",
    ]

    public static let hardcodedRegions: [String] = ["ar", "ca", "cs", "da", "de", "el", "en", "en_AU", "en_GB", "es", "es_419", "fi", "fr", "fr_CA", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "pt", "pt_PT", "ro", "ru", "sk", "sv", "th", "tr", "uk", "vi", "zh_CN", "zh_HK", "zh_TW"]

    public static let fileNameBasedSmallIDs: NSDictionary = [
        "ConnectivityModule.bundle": "connect",
        "MediaControlsModule.bundle": "music",
        "OrientationLockModule.bundle": "rotate",
        "AirPlayMirroringModule.bundle": "airplay",
        "FocusUIModule.bundle": "focusui",
        "DisplayModule.bundle": "screen",
        "MediaControlsAudioModule.bundle": "volume",
        "HomeControlCenterModule.bundle": "home.large",
        "DoNotDisturbModule.bundle": "ios15.dnd",
        "CarModeModule.bundle": "ios15.car",
        "MuteModule.bundle": "mute",
        "PerformanceTraceModule.bundle": "ptrace",
        "SleepModeControlCenterButton.bundle": "ios15.sleep",
        "VideoConferenceControlCenterModule.bundle": "conf.cam",
        "AudioConferenceControlCenterModule.bundle": "conf.mic",
    ]
    
    //literally just inverted above to save cpu
    public static let smallIDBasedFileNames: NSDictionary = [
        "connect": "ConnectivityModule.bundle",
        "music": "MediaControlsModule.bundle",
        "rotate": "OrientationLockModule.bundle",
        "airplay": "AirPlayMirroringModule.bundle",
        "focusui": "FocusUIModule.bundle",
        "screen": "DisplayModule.bundle",
        "volume": "MediaControlsAudioModule.bundle",
        "home.large": "HomeControlCenterModule.bundle",
        "ios15.dnd": "DoNotDisturbModule.bundle",
        "ios15.car": "CarModeModule.bundle",
        "mute": "MuteModule.bundle",
        "ptrace": "PerformanceTraceModule.bundle",
        "ios15.sleep": "SleepModeControlCenterButton.bundle",
        "conf.cam": "VideoConferenceControlCenterModule.bundle",
        "conf.mic": "AudioConferenceControlCenterModule.bundle"
    ]
    
    public static let smallIDBasedModuleIDs: NSDictionary = [
        "connect": "com.apple.control-center.ConnectivityModule",
        "rotate": "com.apple.control-center.OrientationLockModule",
        "airplay": "com.apple.mediaremote.controlcenter.airplaymirroring",
        "ios15.dnd": "com.apple.donotdisturb.DoNotDisturbModule",
        "ios15.car": "com.apple.control-center.CarModeModule",
        "ios15.sleep": "com.apple.sleep.controlcenter.sleepmode",
        "mute": "com.apple.control-center.MuteModule",
        "ptrace": "com.apple.control-center.PerformanceTraceModule",
        "music": "com.apple.mediaremote.controlcenter.nowplaying",
        "focusui": "com.apple.FocusUIModule",
        "screen": "com.apple.control-center.DisplayModule",
        "volume": "com.apple.mediaremote.controlcenter.audio",
        "home.large": "com.apple.Home.ControlCenter"
//        "com.apple.control-center.ConnectivityModule": "connect",
//        "com.apple.control-center.OrientationLockModule": "rotate",
//        "com.apple.mediaremote.controlcenter.airplaymirroring": "airplay",
//        "com.apple.donotdisturb.DoNotDisturbModule": "ios15.dnd",
//        "com.apple.control-center.CarModeModule": "ios15.car",
//        "com.apple.sleep.controlcenter.sleepmode": "ios15.sleep",
//        "com.apple.control-center.MuteModule": "mute",
//        "com.apple.control-center.PerformanceTraceModule": "ptrace",
//        "com.apple.mediaremote.controlcenter.nowplaying": "music",
//         "com.apple.FocusUIModule": "focusui",
//         "com.apple.control-center.DisplayModule": "screen",
//         "com.apple.mediaremote.controlcenter.audio": "volume",
//         "com.apple.Home.ControlCenter": "home.large",
    ]

    public static let fileNameBasedAssetOverrides: NSDictionary = [
        // "filename".car in the bundle of the app
        "ConnectivityModule.bundle": "Connectivity",
        "AccessibilityGuidedAccessControlCenterModule.bundle": "GuidedAccess",
        "MuteModule.bundle": "Mute",
        "TVRemoteModule.bundle": "TVRemote",
        "NFCControlCenterModule.bundle": "NFC",
        "FlashlightModule.bundle": "Flashlight",
        "ReplayKitModule.bundle": "ReplayKit",
    ]
    
    public var hiddenModulesToPatch: [String] {
        var base: [String] = [
            "SilenceCallsCCWidget.bundle",
            "ContinuousExposeModule.bundle",
            "NFCControlCenterModule.bundle",
            "PerformanceTraceModule.bundle",
            "DoNotDisturbModule.bundle",
            "CarModeModule.bundle",
            "MuteModule.bundle",
            "HomeControlCenterModule.bundle",
            "PerformanceTraceModule.bundle",
            "SleepModeControlCenterButton.bundle",
        ]
        if UIDevice.current.userInterfaceIdiom != .pad {
            base.append("KeyboardBrightnessModule.bundle")
        }
        return base
    }

    public static let moduleNames: NSDictionary = [
        "FocusUIModule.bundle": "Focus",
        "MediaControlsAudioModule.bundle": "Volume",
        "MediaControlsModule.bundle": "Media Player",
        "PerformanceTraceModule.bundle": "Performance Tracer",
        "ReplayKitModule.bundle": "Screen Recording",
        "ContinuousExposeModule.bundle": "Stage Manager",
        "HomeControlCenterModule.bundle": "Home (large)",
        "SilenceCallsCCWidget.bundle": "Silence Calls",
        "HomeControlCenterCompactModule.bundle": "Home (small)",
        "OrientationLockModule.bundle": "Orientation Lock",
        "ShazamModule.bundle": "Shazam",
        "TVRemoteModule.bundle": "TV Remote",
        "DisplayModule.bundle": "Brightness",

        "QuickNoteModule.bundle": "Notes",
        "NFCControlCenterModule.bundle": "NFC Tag Reader",
        "KeyboardBrightnessModule.bundle": "Keyboard Brightness",
        "AccessibilityShorcutsModule.bundle": "Accessibility Shortcuts",
        "AudioConferenceControlCenterModule.bundle": "Conference Audio Options",
        "AlarmModule.bundle": "Alarm",
        "ConnectivityModule.bundle": "Connectivity",
        "AccessibilityGuidedAccessControlCenterModule.bundle": "Guided Access",
        "SystemQuickNoteModule.bundle": "Quick Note",
        "AppearanceModule.bundle": "Appearance",
        "MuteModule.bundle": "Mute",
        "MagnifierModule.bundle": "Magnifier",
        "CameraModule.bundle": "Camera",
        "HearingAidsModule.bundle": "Hearing",
        "QRCodeModule.bundle": "QR Code Scanner",
        "VoiceMemosModule.bundle": "Voice Memos",
        "WalletModule.bundle": "Wallet",
        "AccessibilitySoundDetectionControlCenterModule.bundle": "Sound Detection",
        "AirPlayMirroringModule.bundle": "AirPlay Mirroring",
        "StopwatchModule.bundle": "Stopwatch",
        "LowPowerModule.bundle": "Low Power Mode",
        "AccessibilityTextSizeModule.bundle": "Text Size",
        "SpokenNotificationsModule.bundle": "Spoken Notifications",
        "VideoConferenceControlCenterModule.bundle": "Conference Video Options",
        "FlashlightModule.bundle": "Flashlight",
        "FeedbackAssistantModule.bundle": "Feedback Assistant",
        "CalculatorModule.bundle": "Calculator",
        "TimerModule.bundle": "Timer",

        "CarModeModule.bundle": "Driving Focus",
        "SleepModeControlCenterButton.bundle": "Sleep Focus",
        "DoNotDisturbModule.bundle": "Do Not Disturb (iOS 14)",
    ]

    public var moduleSFIcons: NSDictionary {
//        var base = [
//            "com.apple.replaykit.VideoConferenceControlCenterModule": "video",
//            "com.apple.FocusUIModule": "moon.fill",
//            "com.apple.Home.ControlCenter": "homekit",
//            "com.apple.Home.CompactControlCenter": "homekit",
//            "com.apple.control-center.DisplayModule": "sun.max",
//            "com.apple.control-center.OrientationLockModule": "lock.rotation",
//            "com.apple.mediaremote.controlcenter.audio": "speaker.wave.2",
//            "com.apple.control-center.ConnectivityModule": "wifi",
//            "com.apple.control-center.MuteModule": "bell.slash.fill",
//            "com.apple.control-center.QuickNoteModule": "note.text",
//            "com.apple.mobilenotes.SystemPaperControlCenterModule": "note.text",
//            "com.apple.springboard.ContinuousExposeModule": "squares.leading.rectangle",
//            "com.apple.control-center.FlashlightModule": "flashlight.off.fill",
//            "com.apple.control-center.CameraModule": "camera.fill",
//            "com.apple.control-center.LowPowerModule": "battery.25",
//            "com.apple.shazamkit.controlcenter.ShazamModule": "shazam.logo.fill",
//            "com.apple.TelephonyUtilities.SilenceCallsCCWidget": "iphone.homebutton.slash",
//            "com.apple.replaykit.controlcenter.screencapture": "record.circle",
//            "com.apple.replaykit.AudioConferenceControlCenterModule": "mic",
//            "com.apple.control-center.AppleTVRemoteModule": "appletvremote.gen4.fill",
//            "com.apple.control-center.FeedbackAssistanceModule": "exclamationmark.bubble.fill",
//            "com.apple.control-center.PerformanceTraceModule": "waveform.path.ecg",
//            "com.apple.mediaremote.controlcenter.nowplaying": "waveform",
//            // TODO: more.
//        ]

        var base = [
            "VideoConferenceControlCenterModule.bundle": "video",
            "SystemQuickNoteModule.bundle": "note.text",
            "CameraModule.bundle": "camera", // fill?
            "FeedbackAssistantModule.bundle": "exclamationmark.bubble", // fill?
            "ContinuousExposeModule.bundle": "squares.leading.rectangle",
            "AudioConferenceControlCenterModule.bundle": "mic",
            "OrientationLockModule.bundle": "lock.rotation",
            "ShazamModule.bundle": "shazam.logo", // fill?
            "QuickNoteModule.bundle": "note.text",
            "DisplayModule.bundle": "sun.max",
            "HomeControlCenterCompactModule.bundle": "homekit",
            "MediaControlsAudioModule.bundle": "speaker.wave.2",
            "FlashlightModule.bundle": "flashlight.off.fill", // not-fill doesnt exist?
            "HomeControlCenterModule.bundle": "homekit",
            "MediaControlsModule.bundle": "airplayaudio",
            "MuteModule.bundle": "bell.slash", // fill?
            "SilenceCallsCCWidget.bundle": "iphone.homebutton.slash",
            "PerformanceTraceModule.bundle": "waveform.path.ecg",
            "ConnectivityModule.bundle": "wifi",
            "FocusUIModule.bundle": "moon", // fill?
            "ReplayKitModule.bundle": "record.circle",
            "TVRemoteModule.bundle": "appletvremote.gen4", // fill?
            "LowPowerModule.bundle": "battery.25",
            "WalletModule.bundle": "creditcard",

            "AlarmModule.bundle": "alarm", // fill?
            "SleepModeControlCenterButton.bundle": "bed.double", // fill?
            "AccessibilityTextSizeModule.bundle": "textformat.size",
            "StopwatchModule.bundle": "stopwatch", // fill?
            "DoNotDisturbModule.bundle": "moon.zzz", // fill?
            "AccessibilityGuidedAccessControlCenterModule.bundle": "lock.rectangle",
            "AccessibilityShorcutsModule.bundle": "cursorarrow.motionlines", // acc where tf is this icon too omg
            "MagnifierModule.bundle": "plus.magnifyingglass",
            "CalculatorModule.bundle": "function", // wheretf is the calc icon
            "VoiceMemosModule.bundle": "waveform.and.mic",
            "CarModeModule.bundle": "car", // fill?
            "AppearanceModule.bundle": "lightbulb", // fill?
            "SpokenNotificationsModule.bundle": "bell.and.waveform", // fill?
            "NFCControlCenterModule.bundle": "wave.3.right.circle", // fill?
            "QRCodeModule.bundle": "qrcode.viewfinder",
            "AccessibilitySoundDetectionControlCenterModule.bundle": "waveform.and.magnifyingglass",
            "TimerModule.bundle": "timer",
            "HearingAidsModule.bundle": "hearingdevice.ear",
            "KeyboardBrightnessModule.bundle": "light.max",
            "AirPlayMirroringModule.bundle": "airplayvideo",
        ]

        if #available(iOS 16.0, *) {
        } else {
            base["ShazamModule.bundle"] = "music.note.list"
        }
        return base as NSDictionary
    }
}
