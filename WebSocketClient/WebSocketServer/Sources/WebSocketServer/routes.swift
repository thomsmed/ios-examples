import Vapor

struct Item: Codable {
    let id: UUID
    let text: String
}

actor ItemRepository {
    static let shared = ItemRepository()

    private var items: [Item] = [
        Item(id: .init(), text: "Item 1"),
        Item(id: .init(), text: "Item 2"),
        Item(id: .init(), text: "Item 3"),
        Item(id: .init(), text: "Item 4"),
        Item(id: .init(), text: "Item 5"),
    ]

    func get() async -> [Item] {
        items
    }

    func get(withId id: UUID) async -> Item? {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return items[index]
    }

    func set(_ item: Item) async -> Item? {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return nil
        }
        items[index] = item
        return item
    }

    func add(_ item: Item) async {
        items.append(item)
    }

    func delete(withId id: UUID) async -> Item? {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return items.remove(at: index)
    }
}

enum IncomingMessage: Decodable {
    case update(item: Item)
    case add(item: Item)
    case delete(id: UUID)
}

enum OutgoingMessage: Encodable {
    case items(items: [Item])
    case update(item: Item)
    case add(item: Item)
    case delete(item: Item)
}

actor WebSocketRepository {
    static let shared = WebSocketRepository()

    private var webSockets: [WebSocket] = []

    func get() async -> [WebSocket] {
        webSockets
    }

    func add(_ ws: WebSocket) async {
        webSockets.append(ws)
    }

    func remove(_ ws: WebSocket) async {
        webSockets.removeAll(where: { $0 === ws })
    }
}

func routes(_ app: Application) throws {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    app.webSocket("channel") { (req, ws) async in
        await WebSocketRepository.shared.add(ws)

        ws.onClose.whenComplete { _ in
            Task {
                await WebSocketRepository.shared.remove(ws)
            }
        }

        ws.onText { ws, _ async in
            try? await ws.close(code: .unacceptableData)
        }

        ws.onBinary { ws, data async in
            guard let incomingMessage = try? decoder.decode(IncomingMessage.self, from: data) else {
                try? await ws.close(code: .unacceptableData)
                return
            }

            let outgoingMessage: OutgoingMessage
            switch incomingMessage {
                case let .add(item):
                    let newItem = Item(id: UUID(), text: item.text)
                    await ItemRepository.shared.add(newItem)
                    outgoingMessage = .add(item: newItem)

                case let .update(item):
                    guard let updatedItem = await ItemRepository.shared.set(item) else {
                        return
                    }
                    outgoingMessage = .update(item: updatedItem)

                case let .delete(id):
                    guard let deletedItem = await ItemRepository.shared.delete(withId: id) else {
                        return
                    }
                    outgoingMessage = .delete(item: deletedItem)
            }

            guard let data = try? encoder.encode(outgoingMessage) else {
                return
            }

            for ws in await WebSocketRepository.shared.get() {
                try? await ws.send([UInt8](data))
            }
        }

        let outgoingMessage = OutgoingMessage.items(items: await ItemRepository.shared.get())

        guard let data = try? encoder.encode(outgoingMessage) else {
            return
        }

        try? await ws.send([UInt8](data))
    }
}
