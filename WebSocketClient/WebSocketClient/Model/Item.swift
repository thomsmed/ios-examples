//
//  Item.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 13/02/2024.
//

import Foundation

struct Item: Codable {
    let id: UUID
    let text: String
}
