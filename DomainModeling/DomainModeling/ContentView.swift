//
//  ContentView.swift
//  DomainModeling
//
//  Created by Thomas Smedmann on 24/09/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            usingUnions()
            usingComposites()
        }
    }
}

extension ContentView {

    func usingUnions() {
        var union: MyUnion = .one
        union = .three("Three")

        print(union)

        var taggedUnion: MyTaggedUnion<String> = .one
        taggedUnion = .three("Three")
        //taggedUnion = MyTaggedUnion<Int>.one // Not allowed! `taggedUnion` is of type "String tagged MyTaggedUnion"!

        print(taggedUnion)
    }

    func usingComposites() {
        var composite = MyComposite(one: .one, two: 2, three: "Three")
        composite = MyComposite(one: .two(2), two: 3, three: "Four")

        print(composite)

        var taggedComposite = MyTaggedComposite<String>(one: .one, two: 2, three: "Three")
        taggedComposite = MyTaggedComposite<String>(one: .two(2), two: 3, three: "Four")
        //taggedComposite = MyTaggedComposite<Int>(one: .two(2), two: 3, three: "Four") // Not allowed! `taggedComposite` is of type "String tagged MyTaggedComposite"!

        print(taggedComposite)
    }
}

#Preview {
    ContentView()
}
