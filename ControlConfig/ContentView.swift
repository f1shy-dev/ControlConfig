//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Hello, World!")
            }
            .navigationTitle("ControlConfig")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
