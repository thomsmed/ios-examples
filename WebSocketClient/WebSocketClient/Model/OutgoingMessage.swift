//
//  OutgoingMessage.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 17/02/2024.
//

import Foundation

enum OutgoingMessage: Encodable {
    case update(item: Item)
    case add(item: Item)
    case delete(id: UUID)
}
