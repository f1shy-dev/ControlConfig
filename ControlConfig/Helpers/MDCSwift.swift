//
//  MDCSwift.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//  Credits: cowabunga
//
        
import Foundation
import UIKit
import MacDirtyCow

public enum RespringMethod {
    case backboard, frontboard, legacy
}

public enum MDC {
    public static func overwriteFile(at path: String, with data: Data) -> Bool {
        return MacDirtyCow.overwriteFileWithDataImpl(originPath: path, replacementData: data)
    }
    
    public static func respring(method: RespringMethod) {
        switch method {
        case .backboard:
            print("Respringing... (xpc_crasher backboard)")
            let processes = [
                // idk this is only for that cc action ig
//                "com.apple.cfprefsd.daemon",
                "com.apple.backboard.TouchDeliveryPolicyServer",
//                "com.apple.frontboard.systemappservices"
            ]
            for process in processes {
                MacDirtyCow.xpc_crash(process)
            }
        case .frontboard:
            print("Respringing... (xpc_crasher frontboard)")
            let processes = [
                // only kill frontboard since killing backboard doesnt apply cc tweaks??
                "com.apple.cfprefsd.daemon",
                //        "com.apple.backboard.TouchDeliveryPolicyServer",
                "com.apple.frontboard.systemappservices",
            ]
            for process in processes {
                MacDirtyCow.xpc_crash(process)
            }
        case .legacy:
            print("Respringing... (legacy)")
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                guard let window = UIApplication.shared.windows.first else { return }
                while true {
                    window.snapshotView(afterScreenUpdates: false)
                }
            }
        }
    }
}
