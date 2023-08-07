//
//  DebugActionsMenu.swift
//  ControlConfig
//
//  Created by Vrishank Agarwal on 05/08/2023.
//

import SwiftUI

struct DebugActionsMenu: View {
    var body: some View {
        List {
            Button("Print module configuration m-ids (var)") {
                if let dict = PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath), let currentList = dict["module-identifiers"] {
                    print(currentList)
                }
            }

            Button("Print module configuration (var)") {
                print(PlistHelpers.plistToDict(path: CCMappings.moduleConfigurationPath))
            }

            Button("Init some module with BID") {
                print(Module(bundleID: "com.apple.FocusUIModule")?.fileName)
            }

            Button("Print module backup idx0") {
                print(BackupManager.shared.latestBackup?.modules)
            }

            Button("Latest backup path URL") {
                if let xd = BackupManager.shared.latestBackup?.folderPath {
                    do {print(try FileManager.default.contentsOfDirectory(atPath: xd))}
                    catch {print(error)}
                }
            }


            Button("Next level CAML padding bypass >w<") {
                let pl = PlistHelpers.plistToDict(path: "/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle/replaykit.ca/index.xml")
                print(pl)
            }

            Group {
                Button("VNode - /var/mobile write test") {
                    VarMobileWriteTest()
                }
                
                Button("VNode - CCReadTest") {
                    ControlCenterReadTest()
                }
                
                Button("VNode - list files @ /var/mobile/Library") {
                    VarLibrary_ListFiles()
                }
                
                Button("VNode - list files @ /var/mobile") {
                    VarMobile_ListFiles()
                }
                
                Button(action: {
                    print(CCPath_ListFiles())
                }, label: {
                    Text("Path VNode - list files @ var.ControlCenter")
                })
                
                Button("print ccms") {
                    let dict = readCCModuleConf()
                    print(dict)
                }
//                Button("secret") {
//                    print(CCSModuleSettingsProvider.sharedProvider())
//                }
            }
        }
    }
}

struct DebugActionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        DebugActionsMenu()
    }
}
