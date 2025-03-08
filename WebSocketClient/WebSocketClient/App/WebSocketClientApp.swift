//
//  WebSocketClientApp.swift
//  WebSocketClient
//
//  Created by Thomas Asheim Smedmann on 08/02/2024.
//

import SwiftUI

struct WebSocketConnectionFactoryEnvironmentKey: EnvironmentKey {
    static let defaultValue: WebSocketConnectionFactory = DefaultWebSocketConnectionFactory()
}

extension EnvironmentValues {
    var webSocketConnectionFactory: WebSocketConnectionFactory {
        get { self[WebSocketConnectionFactoryEnvironmentKey.self] }
        set { self[WebSocketConnectionFactoryEnvironmentKey.self] = newValue }
    }
}

@main
struct WebSocketClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
