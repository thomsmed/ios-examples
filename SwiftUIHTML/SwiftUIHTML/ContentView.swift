//
//  ContentView.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct ContentView: View {
    private static let simpleHTML: NSAttributedString = .html(withBody: """
        <p>This is a paragraph</p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
        </ul>
        """)

    private static let richHTML: NSAttributedString = .html(withBody: """
        <h1>This is a H1 header</h1>
        <h2>This is a H2 header</h2>
        <h3>This is a H3 header</h3>
        <p>This is a paragraph</p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
        </ul>
        <p>This is another paragraph</p>
        <p>This is a paragraph with a <a href="https://developer.apple.com/">link to some other content</a></p>
        <p style="color: blue; text-align: center;">And this is a <span style="color: red;">paragraph</span> with inline styling</p>
        """)

    @State private var showRichHTML: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("This is a normal SwiftUI Text View. Below is our custom HTML Text View")
                        .padding()

                    Button("Render \(showRichHTML ? "simple" : "rich") HTML") {
                        showRichHTML.toggle()
                    }
                    .padding()

                    AttributedText(showRichHTML ? Self.richHTML : Self.simpleHTML)
                }
            }
            .navigationTitle("HTML in SwiftUI")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
