//
//  ContentView.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.httpClient) private var httpClient: HTTPClient

    @State private var items: [Item] = []

    @State private var currentEditingItemId: UUID = UUID()
    @State private var currentEditingItemText: String = ""

    @State private var errorAlertTitle: String = ""
    @State private var errorAlertMessage: String = ""

    @State private var errorAlertPresented: Bool = false
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

                HStack {
                    Spacer()
                    Button("Provoke Error", role: .destructive, action: provokeError)
                    Spacer()
                }
                .padding()
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
            // Error Alert
            .alert(errorAlertTitle, isPresented: $errorAlertPresented) {
                Button("Ok", role: .cancel) { }
            } message: {
                Text(errorAlertMessage)
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
            // Fetch Items on View appear
            .task(fetchAllItems)
            // Fetch Items on Pull to Refresh
            .refreshable(action: fetchAllItems)
        }
    }
}

// Empty response body
private struct EmptyResponse: Decodable {}

extension ContentView {
    @Sendable func fetchAllItems() async {
        do {
            let url = URL(string: "http://localhost:8080/items")!
            items = try await httpClient.get(
                url: url,
                responseType: .applicationJson
            )
        } catch {
            print("Error fetching Items:", error)
        }
    }

    func saveNewItem() {
        let itemId = currentEditingItemId
        let itemText = currentEditingItemText

        Task {
            do {
                let url = URL(string: "http://localhost:8080/items")!
                let newItem = Item(id: itemId, text: itemText)

                // POST New Item
                let savedNewItem: Item = try await httpClient.post(
                    url: url,
                    requestBody: newItem,
                    requestType: .applicationJson,
                    responseType: .applicationJson
                )

                items.append(savedNewItem)
            } catch {
                print("Error saving new Item:", error)
            }
        }
    }

    func saveExistingItem() {
        let itemId = currentEditingItemId
        let itemText = currentEditingItemText

        Task {
            do {
                let url = URL(string: "http://localhost:8080/items/\(itemId)")!
                let updatedItem = Item(id: itemId, text: itemText)

                // PUT Updated Item
                let savedUpdatedItem: Item = try await httpClient.put(
                    url: url,
                    requestBody: updatedItem,
                    requestType: .applicationJson,
                    responseType: .applicationJson
                )

                guard let index = items.firstIndex(where: { $0.id == savedUpdatedItem.id }) else {
                    return assertionFailure("Expected updated Item to exist")
                }

                items[index] = savedUpdatedItem
            } catch {
                print("Error saving existing Item:", error)
            }
        }
    }

    func deleteItem() {
        let itemId = currentEditingItemId

        Task {
            do {
                let url = URL(string: "http://localhost:8080/items/\(itemId)")!

                // DELETE Item
                let _: Void = try await httpClient.delete(
                    url: url
                )

                guard let index = items.firstIndex(where: { $0.id == itemId }) else {
                    return assertionFailure("Expected deleted Item to exist")
                }

                let _ = items.remove(at: index)
            } catch {
                print("Error deleting Item:", error)
            }
        }
    }

    func provokeError() {
        Task {
            do {
                let url = URL(string: "http://localhost:8080/error")!

                // GET Error (should fail)
                let _: EmptyResponse = try await httpClient.get(
                    url: url,
                    responseType: .applicationJson,
                    interceptors: [],
                    errorBodyType: ErrorBody.self
                )
            } catch HTTPClientError<ErrorBody>.clientError(let errorResponse) {
                guard let errorBody = errorResponse.errorBody else {
                    return assertionFailure("Should never have ended up here")
                }

                errorAlertTitle = errorBody.title
                errorAlertMessage = errorBody.message

                errorAlertPresented.toggle()
            } catch HTTPClientError<ErrorBody>.serverError(let errorResponse) {
                guard let errorBody = errorResponse.errorBody else {
                    return assertionFailure("Should never have ended up here")
                }

                errorAlertTitle = errorBody.title
                errorAlertMessage = errorBody.message

                errorAlertPresented.toggle()
            } catch {
                assertionFailure("Should never have ended up here")
            }
        }
    }
}

#Preview {
    ContentView()
}
