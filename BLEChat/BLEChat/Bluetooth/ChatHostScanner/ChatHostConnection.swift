//
//  ChatHostConnection.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 18/01/2022.
//

import Foundation
import Combine

enum ChatHostConnectionState {
    case connecting
    case connected
    case disconnected
    case error
}

protocol ChatHostConnection: AnyObject {
    var state: AnyPublisher<ChatHostConnectionState, Never> { get }
    var messages: AnyPublisher<String, Never> { get }
    var reactions: AnyPublisher<String, Never> { get }
    func submit(message: String)
    func submit(reaction: String)
    func disconnect()
}
