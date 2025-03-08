//
//  WebSocketConnectionFactory.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 16/02/2024.
//

import Foundation

/// A simple factory protocol for creating concrete instances of ``WebSocketConnection``.
public protocol WebSocketConnectionFactory: Sendable {
    func open<Incoming: Decodable & Sendable, Outgoing: Encodable & Sendable>(at url: URL) -> WebSocketConnection<Incoming, Outgoing>
}

/// A default implementation of ``WebSocketConnectionFactory``.
public final class DefaultWebSocketConnectionFactory: Sendable {
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Initialise a new instance of ``WebSocketConnectionFactory``.
    ///
    /// - Parameters:
    ///   - urlSession: URLSession used for opening WebSockets.
    ///   - encoder: JSONEncoder used to encode outgoing message bodies.
    ///   - decoder: JSONDecoder used to decode incoming message bodies.
    public init(
        urlSession: URLSession = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension DefaultWebSocketConnectionFactory: WebSocketConnectionFactory {
    public func open<Incoming: Decodable & Sendable, Outgoing: Encodable & Sendable>(at url: URL) -> WebSocketConnection<Incoming, Outgoing> {
        let request = URLRequest(url: url)
        let webSocketTask = urlSession.webSocketTask(with: request)

        return WebSocketConnection(
            webSocketTask: webSocketTask,
            encoder: encoder,
            decoder: decoder
        )
    }
}
