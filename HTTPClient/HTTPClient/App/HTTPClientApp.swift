//
//  HTTPClientApp.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 27/08/2023.
//

import SwiftUI

struct HTTPClientEnvironmentKey: EnvironmentKey {
    static var defaultValue: HTTPClient = DefaultHTTPClient()
}

extension EnvironmentValues {
    var httpClient: HTTPClient {
        get { self[HTTPClientEnvironmentKey.self] }
        set { self[HTTPClientEnvironmentKey.self] = newValue }
    }
}

@main
struct HTTPClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
