//
//  MainView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import MarqueeText
import SwiftUI

let placeholderString = "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"
let emptyApp = SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, pngIconPaths: [placeholderString], hiddenFromSpringboard: false)

struct AppListView: View {
    @ObservedObject var customisation: Customisation
    @State private var searchText = ""
    @ObservedObject var appState: AppState = .shared
    @Environment(\.dismiss) var dismiss

    @State var allApps = [emptyApp]
    @State var apps = [emptyApp]
    var body: some View {
        NavigationView {
            List {
                Section {
                    if apps == [emptyApp] {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        ForEach(apps.sorted(by: { app1, app2 in
                            app1.name < app2.name
                        })) { app in
                            Button(action: {
                                if appState.debugMode {
                                    print("=====APP DETAILS=====")
                                    print("Name: \(app.name)")
                                    print("Bundle ID: \(app.bundleIdentifier)")
                                    print("Bundle Path: \(app.bundleURL)")
                                    print("Hidden from springboard (broken): \(app.hiddenFromSpringboard)")
                                    print("Icon paths: \(app.pngIconPaths)")
                                    print("=====================")
                                }
                                customisation.launchAppBundleID = app.bundleIdentifier
                                dismiss()
                            }, label: {
                                HStack(alignment: .center) {
                                    Group {
                                        if app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? placeholderString).path.contains(placeholderString) {
                                            Image("Placeholder")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } else {
                                            let image = UIImage(contentsOfFile: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? placeholderString).path)
                                            Image(uiImage: image ?? UIImage(named: "Placeholder")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        }
                                    }
                                    .cornerRadius(6)
                                    .frame(width: 30, height: 30)

                                    VStack {
                                        HStack {
                                            if app.hiddenFromSpringboard {
                                                MarqueeText(text: "\(app.name) (Hidden)", font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                                    .padding(.horizontal, 6)
                                            } else {
                                                MarqueeText(text: app.name, font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                                                    .padding(.horizontal, 6)
                                            }
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
        .navigationViewStyle(StackNavigationViewStyle())
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
// struct AppListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppListView()
//    }
// }
