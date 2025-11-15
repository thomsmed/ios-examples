//
//  ContentView.swift
//  Localhost
//
//  Created by Thomas Asheim Smedmann on 14/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var urlSession: URLSession = .shared

    var body: some View {
        VStack {
            Button("Try HTTP") {
                let url = URL(string: "http://localhost:5024/helloworld")!
                load(url)
            }
            .padding()

            Button("Try HTTPS") {
                let url = URL(string: "https://localhost:7290/helloworld")!
                load(url)
            }
        }
        .padding()
    }
}

extension ContentView {
    func load(_ url: URL) {
        Task {
            do {
                let (data, _) = try await urlSession.data(from: url) as! (Data, HTTPURLResponse)
                let text = String(data: data, encoding: .utf8) ?? "No data"
                print(text)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
