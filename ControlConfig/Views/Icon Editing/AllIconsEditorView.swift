//
//  CAMLDebugView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 12/04/2023
//

import AEXML
import AssetCatalogWrapper
import SwiftUI

struct AssetCatalog {
    var catalog: CUICatalog
    var collection: [Rendition]
    var filePath: URL
    var module: Module
}

struct AllIconsEditorView: View {
    @EnvironmentObject var appState: AppState
    @State var catalogs: [AssetCatalog] = []

    var body: some View {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let assetFolder = documentsURL.appendingPathComponent("AssetFiles")
        List {
            Section {
                Button(action: {
                    UIApplication.shared.confirmAlert(title: "Confirmation", body: "Are you sure you'd like to reset the icons for ALL catalogs?", onOK: {
                        do {
                            let fileManager = FileManager.default
                            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let assetFolder = documentsURL.appendingPathComponent("AssetWorkspace")
                            if fileManager.fileExists(atPath: assetFolder.path) {
                                try fileManager.removeItem(at: assetFolder)
                            }
                            loadCars()
                        } catch {
                            print(error)
                        }
                    }, noCancel: false)
                }, label: {
                    Label("Reset all icons", systemImage: "arrow.clockwise")
                }).foregroundColor(.red)

                Button(action: {
                    do {
                        var sMap: [Bool] = []
                        for catalog in catalogs {
                            let fileManager = FileManager.default
                            if fileManager.fileExists(atPath: catalog.filePath.path) {
                                try MDC.overwriteFile(at: "\(CCMappings.bundlesPath)\(catalog.module.fileName)/Assets.car", with: try Data(contentsOf: catalog.filePath))
                                print("Write - \(catalog.module.description)", write)
                                sMap.append(true)
                            }
                        }

                        if !sMap.contains(false) {
                            UIApplication.shared.alert(title: "Success!", body: "Overwrote all files successfully...")
                        } else {
                            UIApplication.shared.alert(title: "Failure...", body: "Failed to overwrite some icons...")
                        }

                    } catch {
                        UIApplication.shared.alert(title: "Failure...", body: "Failed to overwrite some icons...")
                        print(error)
                    }
                }, label: {
                    Label("Apply all icons", systemImage: "externaldrive.badge.checkmark")
                })

                Section {
                    Button {
                        MDC.respring(method: .frontboard)
                    } label: {
                        Label("Respring", systemImage: "arrow.counterclockwise")
                    }
                }
            }

            Section(header: Text("App launcher modules")) {
                ForEach(catalogs.filter { cata in
                    cata.collection.flatMap { ren in
                        ren.type == .image && ren.name == "AppIcon"
                    }.contains(true)
                }, id: \.filePath) { car in

                    ForEach(car.collection.filter { ren in
                        ren.type == .image && ren.name == "AppIcon"
                    }, id: \.self) { rendition in
                        NavigationLink(destination: RenditionEditorView(catalog: car.catalog, rendition: rendition, filePath: car.filePath)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(car.module.description)
                                    Text("\(rendition.name) - Scale: \(rendition.cuiRend.scale())").font(.system(size: 10)).foregroundColor(.gray)
                                }
                                Spacer()

                                if let image = rendition.image {
                                    let uiImg = UIImage(cgImage: image)
                                    let scaleFactor = CGFloat(32) / uiImg.size.width
                                    Image(uiImage: uiImg)
                                        .resizable()
                                        .colorInvert().frame(width: uiImg.size.width * scaleFactor, height: uiImg.size.height * scaleFactor)
                                        .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        )
                                }
                            }
                        }.contextMenu {
                            Button {
                                print("Write - \(car.module.description)")
                                do {
                                    let fileManager = FileManager.default
                                    if fileManager.fileExists(atPath: car.filePath.path) {
                                        try MDC.overwriteFile(at: "\(CCMappings.bundlesPath)\(car.module.fileName)/Assets.car", with: try Data(contentsOf: car.filePath))
                                    }
                                } catch {

                                    print(error)
                                }
                            } label: {
                                Label("Apply this catalog only", systemImage: "externaldrive.badge.checkmark")
                            }

                            Button {
                                UIApplication.shared.confirmAlert(title: "Confirmation", body: "Are you sure you'd like to reset the icons for this catalog?", onOK: {
                                    do {
                                        let fileManager = FileManager.default
                                        if fileManager.fileExists(atPath: car.filePath.path) {
                                            try fileManager.removeItem(at: car.filePath)
                                            loadCars()
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }, noCancel: false)
                            } label: {
                                Label("Reset this catalog", systemImage: "arrow.clockwise").foregroundColor(.red)
                            }

                            Button(role: .destructive) {
                                do {
                                    try car.catalog.removeItem(rendition, fileURL: car.filePath)

                                } catch {
                                    UIApplication.shared.alert(title: "Failure!", body: "Failed to delete the rendition...")
                                    loadCars()
                                    print(error)
                                }

                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }.onDelete { idxset in
                        do {
                            for idx in idxset {
                                let ren = car.collection.filter { ren in
                                    ren.type == .image && ren.name == "AppIcon"
                                }[idx]
                                try car.catalog.removeItem(ren, fileURL: car.filePath)
                            }
                        } catch {
                            UIApplication.shared.alert(title: "Failure!", body: "Failed to delete the rendition...")
                            loadCars()
                            print(error)
                        }
                    }
                }
            }.headerProminence(.increased)

            ForEach(catalogs.filter { cata in
                cata.collection.map { ren in
                    ren.type == .image && ren.name != "SettingsIcon" && ren.name != "AppIcon"
                }.contains(true)
            }, id: \.filePath) { car in

                Section(header:
                    HStack {
                        Text(car.module.description)
                        Spacer()
                        Button {
                            do {
                                let fileManager = FileManager.default
                                if fileManager.fileExists(atPath: car.filePath.path) {
                                    try MDC.overwriteFile(at: "\(CCMappings.bundlesPath)\(car.module.fileName)/Assets.car", with: try Data(contentsOf: car.filePath))
                                    UIApplication.shared.alert(title: "Success!", body: "Overwrote the file successfully...")
                                }
                            } catch {
                                UIApplication.shared.alert(title: "Failure...", body: "Failed to overwrite the file...")
                                print(error)
                            }
                        } label: {
                            Image(systemName: "externaldrive.badge.checkmark")
                        }

                        Button {
                            UIApplication.shared.confirmAlert(title: "Confirmation", body: "Are you sure you'd like to reset the icons for this catalog?", onOK: {
                                do {
                                    let fileManager = FileManager.default
                                    if fileManager.fileExists(atPath: car.filePath.path) {
                                        try fileManager.removeItem(at: car.filePath)
                                        loadCars()
                                    }
                                } catch {
                                    print(error)
                                }
                            }, noCancel: false)
                        } label: {
                            Image(systemName: "arrow.clockwise").foregroundColor(.red)
                        }
                    }) {
//                        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)

                        ForEach(car.collection.filter { ren in
                            ren.type == .image && ren.name != "SettingsIcon" && ren.name != "AppIcon"
                        }, id: \.self) { rendition in
                            NavigationLink(destination: RenditionEditorView(catalog: car.catalog, rendition: rendition, filePath: car.filePath)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(rendition.name)
                                        Text("Scale: \(rendition.cuiRend.scale())").font(.system(size: 10)).foregroundColor(.gray)
                                    }
                                    Spacer()

                                    if let image = rendition.image {
                                        let uiImg = UIImage(cgImage: image)
                                        let scaleFactor = CGFloat(32) / uiImg.size.width
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .colorInvert().frame(width: uiImg.size.width * scaleFactor, height: uiImg.size.height * scaleFactor)
                                            .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.accentColor, lineWidth: 2)
                                            )
                                    }
                                }
                            }.contextMenu {
                                Button(role: .destructive) {
                                    do {
                                        try car.catalog.removeItem(rendition, fileURL: car.filePath)
                                    } catch {
                                        UIApplication.shared.alert(title: "Failure!", body: "Failed to delete the rendition...")
                                        loadCars()
                                        print(error)
                                    }

                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }.onDelete { idxset in
                            do {
                                for idx in idxset {
                                    let ren = car.collection.filter { ren in
                                        ren.type == .image && ren.name != "SettingsIcon" && ren.name != "AppIcon"
                                    }[idx]
                                    try car.catalog.removeItem(ren, fileURL: car.filePath)
                                }
                            } catch {
                                UIApplication.shared.alert(title: "Failure!", body: "Failed to delete the rendition...")
                                loadCars()
                                print(error)
                            }
                        }
                    }.headerProminence(.increased)
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitle("Car Icons Editor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadCars() }
    }

    func loadCars() {
        do {
            catalogs = []
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

            let assetFolder = documentsURL.appendingPathComponent("AssetWorkspace")
            if !fileManager.fileExists(atPath: assetFolder.path) {
                try fileManager.createDirectory(atPath: assetFolder.path, withIntermediateDirectories: true, attributes: nil)
            }
            for module in fetchModules().filter({ module in
                //, "DisplayModule.bundle" -
                !["HearingAidsModule.bundle","ContinuousExposeModule.bundle", "ShazamModule.bundle"].contains(module.fileName)
            }) {
                var carFile = URL(fileURLWithPath: BackupManager.shared.latestBackup?.modules[module.fileName]?.asset_path ?? "\(CCMappings.bundlesPath)\(module.fileName)/Assets.car")
                
                if let override = CCMappings.fileNameBasedAssetOverrides[module.fileName] as? String, let fileURL = Bundle.main.url(forResource: override, withExtension: "car") {
                    carFile = fileURL
                }
                if !fileManager.fileExists(atPath: carFile.path) {
                    continue
                }

                let workspaceCarFile = assetFolder.appendingPathComponent("\(module.fileName)_Assets.car")
                if !fileManager.fileExists(atPath: workspaceCarFile.path) {
                    try fileManager.copyItem(at: carFile, to: workspaceCarFile)
                }
                let (cata_t, coll_t) = try AssetCatalogWrapper.shared.renditions(forCarArchive: workspaceCarFile)
                let justRenditions_t = coll_t.flatMap(\.renditions)
                for ren in justRenditions_t {
                    if ren.name == "SettingsIcon" && ren.type == .image {
                        try cata_t.removeItem(ren, fileURL: workspaceCarFile)
                    }
                    if ["AppIcon", "TrueTone", "NightShift"].contains(ren.name) && ren.type == .image && ren.cuiRend.scale() == 1.0 {
                        try cata_t.removeItem(ren, fileURL: workspaceCarFile)
                    }
                }

                let (cata, coll) = try AssetCatalogWrapper.shared.renditions(forCarArchive: workspaceCarFile)
                let justRenditions = coll.flatMap(\.renditions)
                catalogs.append(AssetCatalog(catalog: cata, collection: justRenditions, filePath: workspaceCarFile, module: module))
            }

        } catch {
            print(error)
        }
    }
}
