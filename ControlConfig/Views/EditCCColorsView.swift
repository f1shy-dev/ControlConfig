//
//  EditCCColorsView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 05/03/2023
//

import Combine
import SwiftUI

struct SingleBlurModule: View {
    let cornerR: CGFloat = 17.5
    let oneSide: CGFloat = 68
    let color: Color
    let image: String
    @Binding var intensity: Int

    var body: some View {
        ZStack {
            CIVisualEffectView(effect: UIBlurEffect(style: .light), intensity: $intensity.doubleBinding)
                .frame(width: oneSide, height: oneSide)
                .cornerRadius(cornerR)
            color
                .cornerRadius(cornerR)
                .frame(width: oneSide, height: oneSide)

            Image(systemName: image).font(.system(size: 30))
        }
    }
}

struct EditCCColorsView: View {
    @State private var selectedWallpaper = "iPhone SE"
    @ObservedObject var state: OtherCustomisations

    var body: some View {
        List {
            Section(header: Label("Preview", systemImage: "eye")) {
                HStack {
                    Spacer()
//                    Spacer(minLength: 0)

                    ForEach(["lock.rotation", "flashlight.off.fill", "timer", "camera.fill"], id: \.self) { img in
                        SingleBlurModule(color: state.moduleColor, image: img, intensity: $state.moduleBlur)
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding([.vertical])
                .listRowBackground(ZStack {
                    Image("PreviewWall \(selectedWallpaper)")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: CGFloat(state.moduleBGBlur))
                    state.moduleBGColor

                })

                Picker(selection: $selectedWallpaper, label: Text("Preview Wallpaper")) {
                    ForEach(["iPhone SE", "iPhone 13", "iOS 16 WWDC"], id: \.self) { option in
                        Text(option)
                    }
                }
            }.listRowSeparator(.hidden)
            Section(header: Label("Control Center Background", systemImage: "paintbrush")) {
                ColorPicker("Colour (with opacity)", selection: $state.moduleBGColor)
                HStack {
                    Text("Blur (\(state.moduleBGBlur))")
                    Spacer()
                    Slider(value: $state.moduleBGBlur.doubleBinding, in: 0 ... 100, step: 1) {
                        Text("Blur")
                    } minimumValueLabel: { Text("0") } maximumValueLabel: { Text("100") }.frame(width: 150)
                }
            }

            Section(header: Label("Module Colour", systemImage: "paintbrush")) {
                ColorPicker("Colour (with opacity)", selection: $state.moduleColor)
                HStack {
                    Text("Blur (\(state.moduleBlur))")
                    Spacer()
                    Slider(value: $state.moduleBlur.doubleBinding, in: 0 ... 100, step: 1) {
                        Text("Blur")
                    } minimumValueLabel: { Text("0") } maximumValueLabel: { Text("100") }.frame(width: 150)
                }
            }
        }.navigationBarTitle("Edit CC Colours")
    }
}
