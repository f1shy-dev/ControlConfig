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
    let color: Color?
    let image: String
    @Binding var intensity: Int?

    var body: some View {
        ZStack {
            CIVisualEffectView(effect: UIBlurEffect(style: .light), intensity: $intensity.toUnwrapped(defaultValue: 50).doubleBinding)
                .frame(width: oneSide, height: oneSide)
                .cornerRadius(cornerR)
            (color ?? Color.gray)
                .cornerRadius(cornerR)
                .frame(width: oneSide, height: oneSide)

            Image(systemName: image).font(.system(size: 30))
        }
    }
}

struct EditCCColorsView: View {
    @State private var selectedWallpaper = "iPhone SE"
    @ObservedObject var state: OtherCustomisations
    var saveOCToUserDefaults: () -> Void

    var body: some View {
        let _ = saveOCToUserDefaults()
        List {
            Toggle("Enable Custom CC Colors", isOn: $state.enableCustomColors.toUnwrapped(defaultValue: false))
        
            Section(header: Label("Preview", systemImage: "eye"), footer: Text("Note: This preview isn't 100% accurate to what the actual control center will look like.")) {
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
                        .blur(radius: CGFloat(state.moduleBGBlur ?? 50))
                    state.moduleBGColor

                })

                Picker(selection: $selectedWallpaper, label: Text("Preview Wallpaper")) {
                    ForEach(["iPhone SE", "iPhone 13", "iOS 16 WWDC"], id: \.self) { option in
                        Text(option)
                    }
                }
            }.listRowSeparator(.hidden).disabled(!(state.enableCustomColors ?? false))
            Section(header: Label("Control Center Background", systemImage: "paintbrush")) {
                ColorPicker("Colour (with opacity)", selection: $state.moduleBGColor.toUnwrapped(defaultValue: .gray))
                HStack {
                    Text("Blur (\(state.moduleBGBlur ?? 50))")
                    Spacer()
                    Slider(value: $state.moduleBGBlur.toUnwrapped(defaultValue: 50).doubleBinding, in: 0 ... 100, step: 1) {
                        Text("Blur")
                    } minimumValueLabel: { Text("0") } maximumValueLabel: { Text("100") }.frame(width: 150)
                }
            }.disabled(!(state.enableCustomColors ?? false))

            Section(header: Label("Module Colour", systemImage: "paintbrush")) {
                ColorPicker("Colour (with opacity)", selection: $state.moduleColor.toUnwrapped(defaultValue: .gray))
                HStack {
                    Text("Blur (\(state.moduleBlur ?? 50))")
                    Spacer()
                    Slider(value: $state.moduleBlur.toUnwrapped(defaultValue: 50).doubleBinding, in: 0 ... 100, step: 1) {
                        Text("Blur")
                    } minimumValueLabel: { Text("0") } maximumValueLabel: { Text("100") }.frame(width: 150)
                }
            }.disabled(!(state.enableCustomColors ?? false))
        }.navigationBarTitle("Edit CC Colours").navigationBarTitleDisplayMode(.inline)
    }
}
