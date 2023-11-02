//
//  ExploreView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 15/07/2023.
//

import SwiftUI
//import QuartzCore

struct ExploreView: View {
    @State var selected = 0
    var body: some View {
        
        List {
            Section(header: HStack{
                Text(selected == 0 ? "Icons": "Layouts").animation(.easeInOut)
                if activeExploit == .MDC {
                    Spacer()
                    FancyIconToggle(selected: $selected, leftIcon: "photo.stack", rightIcon: "grid")
                }
            }) {
                if selected == 0 {
                    Text("Icons explore page >w<")
                } else {
                    if activeExploit == .MDC {
                        Text("Layouts explore page :3")
                    }
                }
            }
        }.headerProminence(.increased).navigationTitle("Explore")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
