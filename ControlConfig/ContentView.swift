//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            ChangeSingleBundleView()
                .tabItem {
                    Label("Custom Launchers", systemImage: "app.dashed")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
