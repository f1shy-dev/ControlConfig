//
//  CustomisationCard.swift
//  ControlConfig
//
//  Created by f1shy-dev on 14/02/2023
//

import Foundation
import SwiftUI

struct CustomisationCard: View {
    @State var descString = ""
    @State var showingEditSheet = false
//    @State var customisationList: CustomisationList
    @ObservedObject var customisation: Customisation
    var deleteCustomisation: (_ item: Customisation) -> Void
    var saveToUserDefaults: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Group {
                    Image(systemName: customisation.module.sfIcon)
                        .font(.title2)
                }.frame(width: 30)
                Spacer().frame(width: 10)
                VStack(alignment: .leading) {
                    Text(customisation.module.description)
                        .font(.title3)
                        .foregroundColor(.primary)

                    Text(customisation.description)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()

            }.padding([.horizontal, .top]).frame(maxWidth: .infinity)

            Spacer().frame(height: 10)
            HStack {
//                Toggle("Enabled", isOn: $customisation.isEnabled).labelsHidden().toggleStyle(CheckToggleStyle())
                Button {
                    customisation.objectWillChange.send()
                    customisation.isEnabled.toggle()
                    saveToUserDefaults()
                } label: {
                    Label {
                        Text("Enabled")
                    } icon: {
                        Image(systemName: customisation.isEnabled ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(customisation.isEnabled ? .green : .secondary)
                            .accessibility(label: Text(customisation.isEnabled ? "Checked" : "Unchecked"))
                            .imageScale(.large)
                    }
                }
                .buttonStyle(.bordered).clipShape(Capsule()).foregroundColor(.primary)
                Spacer()
                Button(action: {
                    showingEditSheet.toggle()
                }) { Label("Edit", systemImage: "pencil") }.buttonStyle(.bordered).clipShape(Capsule())
                Button(action: {
                    deleteCustomisation(customisation.self)
                }) { Label("Delete", systemImage: "trash").foregroundColor(.red) }.buttonStyle(.bordered).clipShape(Capsule())

            }.padding([.horizontal, .bottom]).frame(maxWidth: .infinity)
        }
        .background(.regularMaterial)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            saveToUserDefaults()
        }) {
            EditModuleView(customisation: customisation, saveToUserDefaults: saveToUserDefaults)
        }
    }
}
