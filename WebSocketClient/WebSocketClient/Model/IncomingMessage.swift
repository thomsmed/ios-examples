//
//  IncomingMessage.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 17/02/2024.
//

import Foundation

enum IncomingMessage: Decodable {
    case items(items: [Item])
    case update(item: Item)
    case add(item: Item)
    case delete(item: Item)
}
