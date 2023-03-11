//
//  BackupManager.swift
//  ControlConfig
//
//  Created by f1shy-dev on onii-chan, yamete kudasaiiiii.
//

import Combine
import Foundation
import UIKit

struct ModuleBackup {
    var fileName: String
    var info_plist: [String: Any]
}

struct Backup {
    var moduleConfiguration: [String: Any]
    var moduleConfiguration_ccsupport: [String: Any]?
    var moduleAllowedList: [String]
    var defaultModuleSettings: [String: Any]
    var modules: [ModuleBackup]

    // CoreMaterial.framework/modules.materialrecipe
    var cm_modules: [String: Any]
    // CoreMaterial.framework/modulesBackground.materialrecipe
    var cm_modulesBackground: [String: Any]
    // CoreMaterial.framework/moduleFill.visualstyleset
    var cm_moduleFill: [String: Any]
    // CoreMaterial.framework/moduleStroke.visualstyleset
    var cm_moduleStroke: [String: Any]

    var id: String
    var date: Date
}

let backupFolderName = ".DO_NOT_DELETE_ControlConfig"

//
class BackupManager {
    static let shared = BackupManager()
    var backups: [Backup]
    var latestBackup: Backup? {
        self.backups.sorted(by: { $0.date > $1.date }).first
    }

    let backupFolder: String

    private init() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let backupFolder = documentsDir.appendingPathComponent(backupFolderName).path
//
        let backupFolder = "/private/var/mobile/" + backupFolderName
        self.backupFolder = backupFolder

        // make folder
        if !FileManager.default.fileExists(atPath: backupFolder) {
            do {
                try FileManager.default.createDirectory(
                    atPath: backupFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating backup folder: \(error)")
            }
        }

        // load backups
        self.backups = []
        self.loadBackupList()
    }

    func loadBackupList() {
        // read backups.plist and populate backups
        let backupsPlist = self.backupFolder + "/backups.plist"
        if FileManager.default.fileExists(atPath: backupsPlist) {
            if let backupsFile = self.loadPlist(path: backupsPlist),
               let backupInfos = backupsFile["backups"] as? [[String: Any]]
            {
                for backupInfo in backupInfos {
                    if let id = backupInfo["id"] as? String,
                       let backup = self.loadBackup(id: id)
                    {
                        print(backup)
                        self.backups.append(backup)
                    }
                }
            }
        } else {
            self.backups = []
        }
    }

    func loadBackup(id: String) -> Backup? {
        let backupFolder = self.backupFolder + "/" + id
        print(backupFolder)
        let moduleConfiguration = self.loadPlist(path: backupFolder + "/ModuleConfiguration.plist")
        let moduleConfiguration_ccsupport = self.loadPlist(
            path: backupFolder + "/ModuleConfiguration_CCSupport.plist")
        let moduleAllowedList = self.loadList(path: backupFolder + "/ModuleAllowedList.plist")

        var base = "/DefaultModuleSettings~"
        if UIDevice.current.userInterfaceIdiom == .pad {
            base = base + "ipad.plist"
        } else {
            base = base + "iphone.plist"
        }
        let defaultModuleSettings = self.loadPlist(path: backupFolder + base)

        let modulesFolder = backupFolder + "/modules"
        var modules: [ModuleBackup] = []
        do {
            let modulesFiles = try FileManager.default.contentsOfDirectory(atPath: modulesFolder)
            for moduleFile in modulesFiles {
                let modulePath = modulesFolder + "/" + moduleFile
                let info_plist = self.loadPlist(path: modulePath + "/info.plist")
                if let info_plist = info_plist {
                    modules.append(ModuleBackup(fileName: moduleFile, info_plist: info_plist))
                }
            }
        } catch {
            print("Error loading modules: \(error)")
        }

        let cm_modules = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/modules.materialrecipe")
        let cm_modulesBackground = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/modulesBackground.materialrecipe")
        let cm_moduleFill = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/moduleFill.visualstyleset")
        let cm_moduleStroke = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/moduleStroke.visualstyleset")
        // if  let each one of them seperately and print names so that i can see which ones are nil
        if let moduleConfiguration = moduleConfiguration {
            print("moduleConfiguration: yes")
        }
        if let moduleConfiguration_ccsupport = moduleConfiguration_ccsupport {
            print("moduleConfiguration_ccsupport: yes")
        }
        if let moduleAllowedList = moduleAllowedList {
            print("moduleAllowedList: yes")
        }
        if let defaultModuleSettings = defaultModuleSettings {
            print("defaultModuleSettings: yes")
        }
        if let cm_modules = cm_modules {
            print("cm_modules: \(cm_modules.count)")
        }
        if let cm_modulesBackground = cm_modulesBackground {
            print("cm_modulesBackground: yes")
        }
        if let cm_moduleFill = cm_moduleFill {
            print("cm_moduleFill: yes")
        }
        if let cm_moduleStroke = cm_moduleStroke {
            print("cm_moduleStroke: yes")
        }

        if let moduleConfiguration = moduleConfiguration,
           let moduleAllowedList = moduleAllowedList,
           let defaultModuleSettings = defaultModuleSettings,
           let cm_modules = cm_modules,
           let cm_modulesBackground = cm_modulesBackground,
           let cm_moduleFill = cm_moduleFill,
           let cm_moduleStroke = cm_moduleStroke
        {
            return Backup(
                moduleConfiguration: moduleConfiguration,
                moduleConfiguration_ccsupport: moduleConfiguration_ccsupport,
                moduleAllowedList: moduleAllowedList,
                defaultModuleSettings: defaultModuleSettings,
                modules: modules,
                cm_modules: cm_modules,
                cm_modulesBackground: cm_modulesBackground,
                cm_moduleFill: cm_moduleFill,
                cm_moduleStroke: cm_moduleStroke,
                id: id,
                date: Date())
        }
        return nil
    }

    func loadPlist(path: String) -> [String: Any]? {
        if FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path) {
                do {
                    let plist = try PropertyListSerialization.propertyList(
                        from: data, options: [], format: nil)
                    if let plist = plist as? [String: Any] {
                        return plist
                    }
                } catch {
                    print("Error loading plist: \(error)")
                }
            }
        }
        return nil
    }

    func loadList(path: String) -> [String]? {
        if FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path) {
                do {
                    // the file is a list of strings
                    let plist = try PropertyListSerialization.propertyList(
                        from: data, options: [], format: nil)
                    if let plist = plist as? [String] {
                        return plist
                    }
                } catch {
                    print("Error loading plist: \(error)")
                }
            }
        }
        return nil
    }

    // folder structure
    // .DO_NOT_DELETE_CONTROLCONFIG_BACKUPS
    //     - backups.plist (list of backups with date and time)
    //     - <backup id> (folder)
    //         - modules (folder)
    //             - whatveermodule.bundle
    //               - info.plist
    //         - other_files (folder)
    //           - ModuleConfiguration.plist
    //           - ModuleConfiguration_CCSupport.plist
    //           - ModuleAllowedList.plist
    //           - DefaultModuleSettings.plist

    private func copyBackupFile(from: String, id: String) {
        // to is the backup id, get file name from from
        let fileName = from.components(separatedBy: "/").last!
        let to_path = self.backupFolder + "/" + id + "/" + fileName
        do {
            print("Copying \(from) to \(to_path)")
            try FileManager.default.copyItem(atPath: from, toPath: to_path)
        } catch {
            print("Error copying backup file: \(error)")
        }
    }

    func createBackup() {
        // create backup id
        let backupId = UUID().uuidString

        // create backup folder
        let backupFolder = self.backupFolder + "/" + backupId
        do {
            try FileManager.default.createDirectory(
                atPath: backupFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating backup folder: \(error)")
        }
        print("backupFolder", backupFolder)

        for file in [
            CCMappings.moduleConfigurationPath, CCMappings.moduleAllowedListPath,
            CCMappings.moduleConfiguration_ccsupportPath, CCMappings().dmsPath,
        ] {
            // copy file if it exists
            if FileManager.default.fileExists(atPath: file) {
                self.copyBackupFile(from: file, id: backupId)
            }
        }

        // copy corematerial.framework folder to backupFolder
        let corematerialPath = CCMappings.privFrameworksPath + "CoreMaterial.framework"
        let corematerialBackupPath = backupFolder + "/CoreMaterial.framework"
        do {
            print("Copying \(corematerialPath) to \(corematerialBackupPath)")
            try FileManager.default.copyItem(atPath: corematerialPath, toPath: corematerialBackupPath)
        } catch {
            print("Error copying corematerial.framework: \(error)")
        }

        do {
            try FileManager.default.createDirectory(
                atPath: backupFolder + "/modules", withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating backup folder: \(error)")
        }
        // copy modules
        let modulesFolder = CCMappings.bundlesPath
        do {
            let modules = try FileManager.default.contentsOfDirectory(atPath: modulesFolder)
            for module in modules {
                let moduleFolder = modulesFolder + module
                let moduleBackupFolder = backupFolder + "/modules/" + module
                // copy whole folder
                do {
                    print("Copying \(moduleFolder) to \(moduleBackupFolder)")
                    try FileManager.default.copyItem(atPath: moduleFolder, toPath: moduleBackupFolder)
                } catch {
                    print("Error copying module folder: \(error)")
                }
            }
        } catch {
            print("Error getting modules: \(error)")
        }

        // create backups.plist if it doesnt exist and if it does add it to the file

        // file is a list of [BackupInfo] format in backups key and id of latest backup in latest key
        let backupsPlistPath = self.backupFolder + "/backups.plist"
        if !FileManager.default.fileExists(atPath: backupsPlistPath) {
            let backupsPlist = NSMutableDictionary()
            let info =
                [
                    "id": backupId,
                    // timestamp/epoch
                    "date": Date().timeIntervalSince1970,
                ] as [String: Any]
            backupsPlist.setValue([info], forKey: "backups")
            backupsPlist.setValue(backupId, forKey: "latest")
            backupsPlist.write(toFile: backupsPlistPath, atomically: true)

        } else {
            let backupsPlist = NSMutableDictionary(contentsOfFile: backupsPlistPath)!
            var backups = backupsPlist.value(forKey: "backups") as! [[String: Any]]
            let info =
                [
                    "id": backupId,
                    // timestamp/epoch
                    "date": Date().timeIntervalSince1970,
                ] as [String: Any]
            backups.append(info)
            backupsPlist.setValue(backups, forKey: "backups")
            backupsPlist.setValue(backupId, forKey: "latest")
            backupsPlist.write(toFile: backupsPlistPath, atomically: true)
        }
    }
}
