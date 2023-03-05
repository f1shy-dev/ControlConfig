//
//  MainView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI
import MarqueeText

struct AppListView: View {
    @ObservedObject var customisation: Customisation
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @State var allApps = [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    @State var apps = [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    var body: some View {
        NavigationView {
            List {
                Section {
                    if apps == [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)] {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        ForEach(apps) { app in
                            Button(action: {
                                customisation.launchAppBundleID = app.bundleIdentifier
                                dismiss()
                            }, label: {
                                HStack(alignment: .center) {
                                    Group {
                                        if app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path.contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao") {
                                            Image("Placeholder")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } else {
                                            let image = UIImage(contentsOfFile: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path)
                                            Image(uiImage: image ?? UIImage(named: "Placeholder")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        }
                                    }
                                    .cornerRadius(6)
                                    .frame(width: 30, height: 30)
                                    
                                    VStack {
                                        HStack {
                                            MarqueeText(text: app.name, font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                                .padding(.horizontal, 6)
                                            Spacer()
                                        }
                                    }
                                }
                            })
                            .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Pick app")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Close", systemImage: "xmark")
                    })
                }
            }.navigationBarTitleDisplayMode(.inline)
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText) { searchText in

                if !searchText.isEmpty {
                    apps = allApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                } else {
                    apps = allApps
                }
            }
        }
        .onAppear {
            allApps = try! ApplicationManager.getApps()
            apps = allApps
        }
        .refreshable {
            allApps = try! ApplicationManager.getApps()
            apps = allApps
        }
    }
}

// TODO: figure out previews
//struct AppListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppListView()
//    }
//}
