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
//    @State var showingDeleteConfirmation = false
    @Environment(\.editMode) private var editMode
//    @State var customisationList: CustomisationList
    @ObservedObject var customisation: Customisation
    @EnvironmentObject var appState: AppState
    var deleteCustomisation: (_ item: Customisation) -> Void
//    var saveToUserDefaults: () -> Void
//    var sendUpdateToList: () -> Void

    var body: some View {
        HStack {
//                                Image(systemName: )
//                                    .font(.title2)
//                                Text()
//                                    .font(.title3)
//                                    .foregroundColor(.primary)
            Label(customisation.module.description, systemImage: customisation.module.sfIcon)

            Spacer()
            //.buttonStyle(.bordered).clipShape(Capsule()).tint(.gray)
          
                Button(action: {
                    showingEditSheet.toggle()
                }) {
                    Image(systemName: "pencil").foregroundColor(.accentColor)
                }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
        }.padding(EdgeInsets(top: 1.25, leading: 0, bottom: 1.25, trailing: 0))
//        VStack(alignment: .leading) {
//            HStack(alignment: .center) {
//                Group {
//                    Image(systemName: customisation.module.sfIcon)
//                        .font(.title2)
//                }.frame(width: 30)
//                Spacer().frame(width: 10)
//                VStack(alignment: .leading) {
//                    Text(customisation.module.description)
//                        .font(.title3)
//                        .foregroundColor(.primary)
//
//                    Text(customisation.description)
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                Spacer()
//            }
////            .padding([.horizontal, .top]).frame(maxWidth: .infinity)
//            .padding(EdgeInsets(top: 9, leading: 0, bottom: 0, trailing: 0))
//
//            Spacer().frame(height: 10)
//            HStack {
////                Toggle("Enabled", isOn: $customisation.isEnabled).labelsHidden().toggleStyle(CheckToggleStyle())
//                Button {
//                    customisation.objectWillChange.send()
//                    sendUpdateToList()
//                    customisation.isEnabled.toggle()
//                    saveToUserDefaults()
//                } label: {
//                    Label {
//                        Text("Enabled")
//                    } icon: {
//                        Image(systemName: customisation.isEnabled ? "checkmark.circle.fill" : "circle")
//                            .foregroundColor(customisation.isEnabled ? .green : .secondary)
//                            .accessibility(label: Text(customisation.isEnabled ? "Checked" : "Unchecked"))
//                            .imageScale(.large)
//                    }
//                }
//                .buttonStyle(.bordered).clipShape(Capsule()).foregroundColor(.primary).tint(.black)
//                Spacer()
//                Button(action: {
//                    showingEditSheet.toggle()
//                }) { Label("Edit", systemImage: "pencil").foregroundColor(.accentColor) }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
//                Button(action: {
//                    showingDeleteConfirmation = true
////                    deleteCustomisation(customisation.self)
//                }) { Image(systemName: "trash").foregroundColor(.red) }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
//            }
//            .padding(EdgeInsets(top: 0, leading: 0, bottom: 9, trailing: 0))
//            .padding([.horizontal, .bottom])
//                .frame(maxWidth: .infinity)
//        }
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
            appState.currentSet.objectWillChange.send()
        }) {
            EditModuleView(customisation: customisation)
                .headerProminence(.standard)
        }
//        .confirmationDialog("Are you sure you want to delete the customisation \"\(customisation.module.description)\"?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
//            Button("Delete", role: .destructive) {
//                withAnimation {
//                    deleteCustomisation(customisation.self)
//                }
//            }
//
//            Button("Cancel", role: .cancel) {}
//        }
        // TODO: Drag and drop?
//        .contextMenu {
//            Button {
//                showingEditSheet.toggle()
//            } label: {
//                Label("Edit", systemImage: "pencil")
//            }
//            Button(role: .destructive) {
//                withAnimation {
//                    deleteCustomisation(customisation.self)
//                }
//
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//        }
    }
}
struct CustomisationCard_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach((1...10).reversed(), id: \.self) {_ in
                CustomisationCard(customisation: Customisation(module: Module(fileName: "uwu")), deleteCustomisation: {item in})
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8 ))

            }
        }
        .listStyle(.automatic)
        .listRowInsets(EdgeInsets())
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
        .padding(20)
    }
}
