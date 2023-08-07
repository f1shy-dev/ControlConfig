//
//  MDCSwift.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//  Credits: cowabunga
//
        
import Foundation
import UIKit

public enum RespringMethod {
    case backboard, frontboard, legacy
}

public enum MDC {
    public static func overwriteFile(at path: String, with data: Data) throws {
        if activeExploit == .MDC {
            if !overwriteFileWithDataImpl(originPath: path, replacementData: data) {
                throw "overwrite mdc didnt work"
            }
        } else {
            if kfd == 0 {
                let appState = AppState.shared
                let puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048]
                let puaf_pages = puaf_pages_options[appState.puaf_pages_index]
                print("puaf_pages: \(puaf_pages)")
                kfd = do_kopen(UInt64(puaf_pages), UInt64(appState.puaf_method), UInt64(appState.kread_method), UInt64(appState.kwrite_method))
                do_fun()
            }
            if FileManager.default.fileExists(atPath: URL.documents.appendingPathComponent("TempOverwriteFile").path) {
                try? FileManager.default.removeItem(at: URL.documents.appendingPathComponent("TempOverwriteFile"))
            }
            try data.write(to: URL.documents.appendingPathComponent("TempOverwriteFile"))
            let replacementURL = URL.documents.appendingPathComponent("TempOverwriteFile")
            let cPathtoTargetFile = path.withCString { ptr in
                return strdup(ptr)
            }
            let mutablecPathtoTargetFile = UnsafeMutablePointer<Int8>(mutating: cPathtoTargetFile)
            let cFileURL = replacementURL.path.withCString { ptr in
                return strdup(ptr)
            }
            let mutablecFileURL = UnsafeMutablePointer<Int8>(mutating: cFileURL)
            let result = funVnodeOverwrite2(cPathtoTargetFile, mutablecFileURL) // the magic is here
            if result != 0 { throw "vnodeoverwrite didnt work, check console" }
        }
    }
    
    public static func respring(method: RespringMethod) {
        switch method {
        case .backboard:
            print("🔁 Respringing... (xpc_crasher backboard)")
            let processes = [
                // idk this is only for that cc action ig
//                "com.apple.cfprefsd.daemon",
                "com.apple.backboard.TouchDeliveryPolicyServer",
//                "com.apple.frontboard.systemappservices"
            ]
            for process in processes {
                xpc_crash(process)
            }
        case .frontboard:
            print("🔁 Respringing... (xpc_crasher frontboard)")
            let processes = [
                // only kill frontboard since killing backboard doesnt apply cc tweaks??
                "com.apple.cfprefsd.daemon",
                //        "com.apple.backboard.TouchDeliveryPolicyServer",
                "com.apple.frontboard.systemappservices",
            ]
            for process in processes {
                xpc_crash(process)
            }
        case .legacy:
            print("🔁 Respringing... (legacy)")
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                guard let window = UIApplication.shared.windows.first else { return }
                while true {
                    window.snapshotView(afterScreenUpdates: false)
                }
            }
        }
    }
    
    public static func toggleCatalogCorruption(at path: String, corrupt: Bool) throws {
        let fd = open(path, O_RDONLY | O_CLOEXEC)
        guard fd != -1 else { throw "Could not open target file" }
        defer { close(fd) }
        
        let buffer = UnsafeMutablePointer<Int>.allocate(capacity: 0x4000)
        let n = read(fd, buffer, 0x4000)
        var byteArray = [UInt8](Data(bytes: buffer, count: n))
        
        let treeBytes: [UInt8] = [0, 0, 0, 0, 0x74, 0x72, 0x65, 0x65, 0, 0, 0]
        let corruptBytes: [UInt8] = [67, 111, 114, 114, 117, 112, 116, 84, 104, 105, 76]
        
        let findBytes = corrupt ? treeBytes : corruptBytes
        let replaceBytes = corrupt ? corruptBytes : treeBytes
        
        var startIndex = 0
        while startIndex <= byteArray.count - findBytes.count {
            let endIndex = startIndex + findBytes.count
            let subArray = Array(byteArray[startIndex..<endIndex])
            
            if subArray == findBytes {
                byteArray.replaceSubrange(startIndex..<endIndex, with: replaceBytes)
                startIndex += replaceBytes.count
            } else {
                startIndex += 1
            }
        }
        
        let overwriteSucceeded = byteArray.withUnsafeBytes { dataChunkBytes in
            unaligned_copy_switch_race(
                fd, 0, dataChunkBytes.baseAddress, dataChunkBytes.count)
        }
        print("overwriteSucceeded = \(overwriteSucceeded)")
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
