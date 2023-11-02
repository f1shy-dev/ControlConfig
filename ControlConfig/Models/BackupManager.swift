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
    var info_path: String
    var asset_path: String?
}


let backupFolderName = ".DO_NOT_DELETE_ControlConfig"
let backupFolder = "/private/var/mobile/" + backupFolderName
let bkFolder = backupFolder

struct Backup: Hashable {
    var moduleConfiguration: [String: Any]
    var moduleConfiguration_ccsupport: [String: Any]?
    var moduleAllowedList: [String]
    var defaultModuleSettings: [String: Any]
    var modules: [String: ModuleBackup]

    // CoreMaterial.framework/modules.materialrecipe
    var cm_modules: [String: Any]
    // CoreMaterial.framework/modulesBackground.materialrecipe
    var cm_modulesBackground: [String: Any]
    // CoreMaterial.framework/moduleFill.visualstyleset
    var cm_moduleFill: [String: Any]
    // CoreMaterial.framework/moduleStroke.visualstyleset
    var cm_moduleStroke: [String: Any]

    var id: String
    var folderPath: String {
        BackupManager.shared.backupFolder + "/\(id)/"
    }
    var date: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: Backup, rhs: Backup) -> Bool {
        return lhs.id == rhs.id
    }
}

//
class BackupManager {
    static let shared = BackupManager()
    var backups: [Backup]
    var latestBackup: Backup? {
        self.backups.sorted(by: { $0.date > $1.date }).first
    }

    let backupFolder: String

    private init() {
//        let backupFolder = documentsDir.appendingPathComponent(backupFolderName).path
//
        if activeExploit == .MDC {
            self.backupFolder = bkFolder
        } else {
            self.backupFolder = URL.documents.appendingPathComponent("CCBackups").path
        }

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
        let backupsPlistPath = self.backupFolder + "/backups.plist"
        if FileManager.default.fileExists(atPath: backupsPlistPath) {
            if let backupsFile = self.loadPlist(path: backupsPlistPath),
               let backupInfos = backupsFile["backups"] as? [[String: Any]]
            {
                for backupInfo in backupInfos {
                    if let id = backupInfo["id"] as? String,
                       let backup = self.loadBackup(id: id)
                    {
                        self.backups.append(backup)
                        self.backups = Array(Set(self.backups))
                    }
                }
            }
        }
        
        if !FileManager.default.fileExists(atPath: backupsPlistPath) || self.backups.count == 0 {
            if #available(iOS 16.0, *) {
                if let bundledBackupURL = Bundle.main.url(forResource: "iOS16_CCBackup", withExtension: "zip") {
                    print(bundledBackupURL, "loading bundled")
                    let backupFolderURL = URL(fileURLWithPath: self.backupFolder)
                    do {
                        let backupURL = backupFolderURL.appendingPathComponent("bundled_backup_16")
                        if FileManager.default.fileExists(atPath: backupFolderURL.path) {
                            try FileManager.default.removeItem(at: backupFolderURL)
                        }
                        do {
                            try FileManager.default.createDirectory(
                                atPath: backupURL.path, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print("Error creating backup folder: \(error)")
                        }
                        
                        try FileManager.default.unzipItem(at: bundledBackupURL, to: backupURL)
                        if let backup = self.loadBackup(id: "bundled_backup_16") {
                            self.backups.append(backup)
                            self.backups = Array(Set(self.backups))
                            
                            
                            let backupsPlist = NSMutableDictionary()
                            let info =
                                [
                                    "id": "bundled_backup_16",
                                    // timestamp/epoch
                                    "date": Date().timeIntervalSince1970,
                                ] as [String: Any]
                            backupsPlist.setValue([info], forKey: "backups")
                            backupsPlist.setValue("bundled_backup_16", forKey: "latest")
                            backupsPlist.write(toFile: backupsPlistPath, atomically: true)
                        }
                    } catch {
                        print("Error unzipping bundled backup: \(error)")
                    }
                }
            } else {
                self.backups = []
            }
        }
    }

    func loadBackup(id: String) -> Backup? {
        let backupFolder = self.backupFolder + "/" + id
        print("🗄️ Loading backup \(id)")
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
        var modules: [String: ModuleBackup] = [:]
        do {
            let modulesFiles = try FileManager.default.contentsOfDirectory(atPath: modulesFolder)
            for moduleFile in modulesFiles {
                let modulePath = modulesFolder + "/" + moduleFile
                let info_plist = self.loadPlist(path: modulePath + "/Info.plist")
                if let info_plist = info_plist {
                    if FileManager.default.fileExists(atPath: modulePath + "/Assets.car") {
                        modules[moduleFile] = ModuleBackup(fileName: moduleFile, info_plist: info_plist, info_path:modulePath + "/Info.plist", asset_path: modulePath + "/Assets.car")
                    } else {
                        modules[moduleFile] = ModuleBackup(fileName: moduleFile, info_plist: info_plist,info_path: modulePath + "/Info.plist")
                    }
                }
            }
        } catch {
            print("⛔️ Error loading backup modules: \(error)")
        }

        let cm_modules = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/modules.materialrecipe")
        let cm_modulesBackground = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/modulesBackground.materialrecipe")
        let cm_moduleFill = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/moduleFill.visualstyleset")
        let cm_moduleStroke = self.loadPlist(
            path: backupFolder + "/CoreMaterial.framework/moduleStroke.visualstyleset")
            
        // create a dictionary to store the values
            var dictionary: [String: Bool] = [:]

            // check if each element is nil or not and store the result in the dictionary
            dictionary["moduleConfiguration"] = moduleConfiguration != nil
            dictionary["moduleAllowedList"] = moduleAllowedList != nil
            dictionary["defaultModuleSettings"] = defaultModuleSettings != nil
            dictionary["cm_modules"] = cm_modules != nil
            dictionary["cm_modulesBackground"] = cm_modulesBackground != nil
            dictionary["cm_moduleFill"] = cm_moduleFill != nil
            dictionary["cm_moduleStroke"] = cm_moduleStroke != nil
        
        print("bStatus", dictionary)


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
                    print("⛔️ Error loading backup plist: \(error)")
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
            CCMappings.moduleAllowedListPath, CCMappings().dmsPath, CCMappings.moduleConfigurationPath, CCMappings.moduleConfiguration_ccsupportPath
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
