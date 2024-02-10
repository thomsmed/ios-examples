import Vapor

enum ItemError: Error {
    struct ErrorResponse: Content {
        let title: String
        let message: String
    }

    case notAllowed
}

extension ItemError: AsyncResponseEncodable {
    func encodeResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")

        switch self {
            case .notAllowed:
                let errorResponse = ErrorResponse(
                    title: "Not allowed",
                    message: "You are not allowed to do this!"
                )
                let response: Response = .init(status: .forbidden, headers: headers)
                try response.content.encode(errorResponse)
                return response
        }
    }
}

struct Item: Content {
    let id: UUID
    let text: String
}

struct ItemRequestDTO: Content {
    let text: String
}

struct ItemResponseDTO: Content {
    let id: UUID
    let text: String
}

var items: [Item] = [
    Item(id: .init(), text: "Item 1"),
    Item(id: .init(), text: "Item 2"),
    Item(id: .init(), text: "Item 3"),
    Item(id: .init(), text: "Item 4"),
    Item(id: .init(), text: "Item 5"),
]

func routes(_ app: Application) throws {
    app.get("items") { req async throws in
        items
    }

    app.get("items", ":id") { req async throws in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            fatalError("Expected id to be present")
        }

        guard let item = items.first(where: { $0.id == id }) else {
            throw Abort(.notFound)
        }

        return ItemResponseDTO(id: item.id, text: item.text)
    }

    app.put("items", ":id") { req async throws in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            fatalError("Expected id to be present")
        }

        let updatedItemDTO = try req.content.decode(ItemRequestDTO.self)

        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw Abort(.notFound)
        }

        let updatedItem = Item(id: id, text: updatedItemDTO.text)
        items[index] = updatedItem

        return ItemResponseDTO(id: updatedItem.id, text: updatedItem.text)
    }

    app.post("items") { req async throws in
        let newItemDTO = try req.content.decode(ItemRequestDTO.self)

        let newItem = Item(id: UUID(), text: newItemDTO.text)

        items.append(newItem)

        return ItemResponseDTO(id: newItem.id, text: newItem.text)
    }

    app.delete("items", ":id") { req async throws in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            fatalError("Expected id to be present")
        }

        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw Abort(.notFound)
        }

        let deletedItem = items.remove(at: index)

        return ItemResponseDTO(id: deletedItem.id, text: deletedItem.text)
    }

    app.get("error") { req async throws in
        return ItemError.notAllowed
    }
}
