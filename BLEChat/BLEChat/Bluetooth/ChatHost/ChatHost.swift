//
//  ChatHost.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 14/01/2022.
//

import Foundation
import Combine

enum ChatHostState {
    case off
    case ready
    case unauthorised
    case broadcasting
}

protocol ChatHost: AnyObject {
    var state: AnyPublisher<ChatHostState, Never> { get }
    var messages: AnyPublisher<String, Never> { get }
    var reactions: AnyPublisher<String, Never> { get }

    func startBroadcast()
    func stopBroadcast()
    func submit(message: String)
    func submit(reaction: String)
}
