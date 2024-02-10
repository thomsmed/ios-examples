//
//  ContentView.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.httpClient) private var httpClient: HTTPClient

    @State private var items: [Item] = [
        Item(id: .init(), text: "Item 1"),
        Item(id: .init(), text: "Item 2"),
        Item(id: .init(), text: "Item 3"),
        Item(id: .init(), text: "Item 4"),
        Item(id: .init(), text: "Item 5"),
    ]

    @State private var currentEditingItemId: UUID = UUID()
    @State private var currentEditingItemText: String = ""

    @State private var newItemAlertPresented: Bool = false
    @State private var editItemAlertPresented: Bool = false
    @State private var deleteItemConfirmationPresented: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView([.vertical]) {
                LazyVStack {
                    ForEach(items, id: \.id) { item in
                        ItemView(text: item.text) {
                            // Prepare form for editing of existing Item.
                            currentEditingItemId = item.id
                            currentEditingItemText = item.text

                            editItemAlertPresented.toggle()
                        } delete: {
                            // Prepare form for deletion of existing Item.
                            currentEditingItemId = item.id
                            currentEditingItemText = item.text

                            deleteItemConfirmationPresented.toggle()
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Items")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        // Prepare form for editing of new Item.
                        currentEditingItemId = UUID()
                        currentEditingItemText = ""

                        newItemAlertPresented.toggle()
                    }
                    .labelStyle(.iconOnly)
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Text("\(items.count) Items")
                }
            }
            // New Item Alert
            .alert("New Item", isPresented: $newItemAlertPresented) {
                TextField("Text", text: $currentEditingItemText)
                Button("Cancel", role: .cancel) { }
                Button("Ok", action: saveNewItem)
            }
            // Edit existing Item Alert
            .alert("Edit Item", isPresented: $editItemAlertPresented) {
                TextField("Text", text: $currentEditingItemText)
                Button("Cancel", role: .cancel) { }
                Button("Ok", action: saveExistingItem)
            }
            // Delete existing Item Confirmation
            .confirmationDialog("Delete Item", isPresented: $deleteItemConfirmationPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive, action: deleteItem)
            } message: {
                Text("Delete \"\(currentEditingItemText)\"?")
            }
        }
    }
}

extension ContentView {
    func fetchAllItems() {
        print("Fetching Items")
    }

    func saveNewItem() {
        print("Saving New Item \"\(currentEditingItemText)\" with id: \(currentEditingItemId)")
    }

    func saveExistingItem() {
        print("Saving Existing Item \"\(currentEditingItemText)\" with id: \(currentEditingItemId)")
    }

    func deleteItem() {
        print("Deleting Item \"\(currentEditingItemText)\" with id: \(currentEditingItemId)")
    }
}

#Preview {
    ContentView()
}
