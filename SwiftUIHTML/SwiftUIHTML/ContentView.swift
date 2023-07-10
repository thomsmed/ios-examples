//
//  ContentView.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    HTML("""
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
                        .padding()

                    Text("A normal SwiftUI Text View")
                        .padding()
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
