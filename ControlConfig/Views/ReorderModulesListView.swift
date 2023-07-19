//
//  ReorderModulesListView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 09/04/2023
//

import Foundation
import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let title: String
}

struct ReorderModulesListView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var customisations: CustomisationList
    @State private var items: [Item] = (0 ..< 5).map { Item(title: "Item #\($0)") }
    @State private var itemsToBe: [Item] = (7 ..< 15).map { Item(title: "Item #\($0)") }

    var body: some View {
        List {
            Section {
//                    List {
                ForEach(items) { item in
                    Text(item.title)
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)

//                    }
            } header: {
                Text("Added modules")
            }

            Section {
                ForEach(itemsToBe) { item in
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.white)
                            .background(Color.green)
                            .clipShape(Circle())
                            .onTapGesture {
                                print("pressed? - \(item.title)")
                                itemsToBe.removeAll { idx in
                                    idx.id == item.id
                                }
                                withAnimation(.spring()) {
                                    items.append(item)
                                }
                            }

                        Spacer().frame(width: 18, height: 0)
                        Text(item.title)
                    }
//                    .transition(.opacity)
                }
            } header: {
                Text("More modules")
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitle("New customisation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { editMode?.wrappedValue = .active }
    }

    private func onDelete(offsets: IndexSet) {
//        print(offsets)
        offsets.forEach { idx in
            print("removing \(items[idx].title)")
            itemsToBe.append(items[idx])
            items.remove(at: idx)
        }
    }

    // 3.
    private func onMove(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct DroppableList: View {
    let title: String
    @Binding var users: [String]

    // this action is performed when a drop is made
    // parameters are:
    //  the dropped String
    //  the index where it was dropped
    // it's Optional in case we don't need to anything else
    let action: ((String, Int) -> Void)?

    init(_ title: String, users: Binding<[String]>, action: ((String, Int) -> Void)? = nil) {
        self.title = title
        self._users = users // assign to the Binding, nont the WrappedValue
        self.action = action
    }

    var body: some View {
        List {
            ForEach(users, id: \.self) { user in
                Text(user)
                    .onDrag { NSItemProvider(object: user as NSString) }
            }
            .onMove(perform: moveUser)
            .onInsert(of: ["public.text"], perform: dropUser)
        }
    }

    func moveUser(from source: IndexSet, to destination: Int) {
        users.move(fromOffsets: source, toOffset: destination)
    }

    func dropUser(at index: Int, _ items: [NSItemProvider]) {
        for item in items {
            _ = item.loadObject(ofClass: String.self) { droppedString, _ in
                if let ss = droppedString, let dropAction = action {
                    DispatchQueue.main.async {
                        dropAction(ss, index)
                    }
                }
            }
        }
    }
}
