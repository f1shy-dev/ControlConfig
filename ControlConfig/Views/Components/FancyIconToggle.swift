//
//  FancyIconToggle.swift
//  ControlConfig
//
//  Created by f1shy-dev on 16/07/2023.
//

struct NoPressButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color.white.opacity(0))

    }
    
}


import SwiftUI
struct FancyIconToggle: View {
    @Binding var selected: Int
    var leftIcon: String
    var rightIcon: String
    func toggleSelected() {
        self.selected = self.selected == 0 ? 1 : 0
    }
    var body: some View {
        HStack {
            Button(action: {
                withAnimation{
                   toggleSelected()
                }
                Haptic.shared.play(.medium)
            }) {
                Image(systemName: leftIcon)
                    .font(.system(size: 19))
                    .foregroundColor(self.selected == 0 ? .white : .gray)
                                    .animation(.easeInOut)
            }
            .padding(.leading, 8)
            .buttonStyle(NoPressButtonStyle())
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    toggleSelected()
                }
                Haptic.shared.play(.medium)
            }) {
                Image(systemName: rightIcon)
                    .font(.system(size: 19))
                    .foregroundColor(self.selected == 1 ? .white : .gray)
                    .animation(.easeInOut)
            }
            .padding(.trailing, 8)
            .buttonStyle(NoPressButtonStyle())
        }
        .background(
            ZStack{
                Capsule()
                    .fill(.thickMaterial)
                    .frame(width: 80, height: 36)
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: 40, height: 36)
                    .offset(x: self.selected == 0 ? -20 : 20)
                    .animation(.spring(response: 0.4))
            }
        )
//        .overlay(
//
//        )
        .frame(width: 80, height: 36)
    }
}

struct FancyIconToggle_Previews: PreviewProvider {
    @State static var intValue = 0

    static var previews: some View {
        FancyIconToggle(selected: $intValue, leftIcon: "photo.stack", rightIcon: "grid")
    }
}
