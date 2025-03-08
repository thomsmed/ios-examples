//
//  ContentView.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 08/02/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.webSocketConnectionFactory) private var webSocketConnectionFactory: WebSocketConnectionFactory

    @State private var webSocketConnectionTask: Task<Void, Never>? = nil
    @State private var connection: WebSocketConnection<IncomingMessage, OutgoingMessage>? = nil

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
            // Open WebSocket Connection and start receiving messages on View appear
            .onAppear {
                webSocketConnectionTask?.cancel()

                webSocketConnectionTask = Task {
                    await openAndConsumeWebSocketConnection()
                }
            }
            // Refresh WebSocket Connection on Pull to Refresh
            .refreshable {
                webSocketConnectionTask?.cancel()

                webSocketConnectionTask = Task {
                    await openAndConsumeWebSocketConnection()
                }
            }
            // Close WebSocket Connection on View disappear
            .onDisappear {
                webSocketConnectionTask?.cancel()
            }
        }
    }
}

extension ContentView {
    func openAndConsumeWebSocketConnection() async {
        let url = URL(string: "ws://127.0.0.1:8080/channel")!

        // Close any existing WebSocketConnection
        if let connection {
            connection.close()
        }

        let connection: WebSocketConnection<IncomingMessage, OutgoingMessage> = webSocketConnectionFactory.open(at: url)

        self.connection = connection

        do {
            // Start consuming IncomingMessages
            for try await message in connection.receive() {
                switch message {
                    case let .items(items):
                        self.items = items

                    case let .add(item):
                        items.append(item)

                    case let .update(item):
                        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
                            return assertionFailure("Expected updated Item to exist")
                        }

                        items[index] = item

                    case let .delete(item):
                        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
                            return assertionFailure("Expected deleted Item to exist")
                        }

                        let _ = items.remove(at: index)
                }
            }

            print("IncomingMessage stream ended")
        } catch {
            print("Error receiving messages:", error)
        }
    }

    func saveNewItem() {
        let itemId = currentEditingItemId
        let itemText = currentEditingItemText

        guard let connection else {
            return assertionFailure("Expected Connection to exist")
        }

        Task {
            do {
                let newItem = Item(id: itemId, text: itemText)

                try await connection.send(.add(item: newItem))
            } catch {
                print("Error saving new Item:", error)
            }
        }
    }

    func saveExistingItem() {
        let itemId = currentEditingItemId
        let itemText = currentEditingItemText

        guard let connection else {
            return assertionFailure("Expected Connection to exist")
        }

        Task {
            do {
                let updatedItem = Item(id: itemId, text: itemText)

                try await connection.send(.update(item: updatedItem))
            } catch {
                print("Error saving existing Item:", error)
            }
        }
    }

    func deleteItem() {
        let itemId = currentEditingItemId

        guard let connection else {
            return assertionFailure("Expected Connection to exist")
        }

        Task {
            do {
                try await connection.send(.delete(id: itemId))
            } catch {
                print("Error deleting Item:", error)
            }
        }
    }
}

#Preview {
    ContentView()
}
