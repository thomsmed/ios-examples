//
//  ContentView.swift
//  OpaqueValue
//
//  Created by Thomas Asheim Smedmann on 14/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var opaqueValue: OpaqueValue = {
        let jsonData = Data("""
                {
                    "object": {
                        "string": "Hello World"
                    },
                    "array": ["Hello", "World"],
                    "string": "Hello World",
                    "number": 1337,
                    "boolean": true,
                    "null": null
                }
                """.utf8)

        return try! JSONDecoder().decode(OpaqueValue.self, from: jsonData)
    }()

    var body: some View {
        VStack {
            Text("Representing arbitrary JSON as an opaque Codable type")
                .font(.headline)
                .padding()

            Text("The opaque type consists of one or more primitive types and/or one or more nested Opaque types")
                .font(.subheadline)
                .padding()

            Text(String(describing: opaqueValue))
                .font(.body)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
