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
    @ObservedObject var appState: AppState
    var deleteCustomisation: (_ item: Customisation) -> Void
    var saveToUserDefaults: () -> Void
    var sendUpdateToList: () -> Void

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
            }
//            .padding([.horizontal, .top]).frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

            Spacer().frame(height: 10)
            HStack {
//                Toggle("Enabled", isOn: $customisation.isEnabled).labelsHidden().toggleStyle(CheckToggleStyle())
                Button {
                    customisation.objectWillChange.send()
                    sendUpdateToList()
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
                .buttonStyle(.bordered).clipShape(Capsule()).foregroundColor(.primary).tint(.black)
                Spacer()
                Button(action: {
                    showingEditSheet.toggle()
                }) { Label("Edit", systemImage: "pencil").foregroundColor(.accentColor) }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
                Button(action: {
                    deleteCustomisation(customisation.self)
                }) { Image(systemName: "trash").foregroundColor(.red) }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
//            .padding([.horizontal, .bottom])
//                .frame(maxWidth: .infinity)
        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .contentShape(Rectangle())
//        .background(.regularMaterial)
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
//        )
//        .padding([.top])
//        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            saveToUserDefaults()
        }) {
            EditModuleView(customisation: customisation, appState: appState, saveToUserDefaults: saveToUserDefaults)
        }
        // TODO: Drag and drop?
        .contextMenu {
            Button {
                showingEditSheet.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                deleteCustomisation(customisation.self)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
