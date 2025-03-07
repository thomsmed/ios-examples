//
//  ContentView.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct AttributedStrings {
    let simpleHTML: NSAttributedString = .html(withBody: """
        <p>This is a paragraph</p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
        </ul>
        """)

    let simpleLongHTML: NSAttributedString = .html(withBody: """
        <p>This is a paragraph</p>
        <ul>
            <li>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.</li>
            <li>Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.</li>
        </ul>
        """)

    let richHTML: NSAttributedString = .html(withBody: """
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

    let richLongHTML: NSAttributedString = .html(withBody: """
        <h1>This is a H1 header</h1>
        <h2>This is a H2 header</h2>
        <h3>This is a H3 header</h3>
        <p>This is a paragraph</p>
        <ul>
            <li>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.</li>
            <li>Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.</li>
        </ul>
        <p>This is another paragraph</p>
        <p>This is a paragraph with a <a href="https://developer.apple.com/">link to some other content</a></p>
        <p style="color: blue; text-align: center;">And this is a <span style="color: red;">paragraph</span> with inline styling</p>
        """)
}

struct ContentView: View {
    @State private var attributedStrings = AttributedStrings()

    @State private var renderLongHTML: Bool = false
    @State private var renderRichHTML: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This is a normal SwiftUI Text View. Below is our custom HTML Text View")
                        .padding(.horizontal, 32)

                    Toggle(isOn: $renderLongHTML) {
                        Text("Long HTML")
                    }
                    .padding(.horizontal, 32)

                    Toggle(isOn: $renderRichHTML) {
                        Text("Rich HTML")
                    }
                    .padding(.horizontal, 32)
                }

                if #available(iOS 16.0, *) {
                    AttributedText(attributedStringBasedOnOptions)
                        .scrollDisabled(true)
                } else {
                    AttributedText(attributedStringBasedOnOptions, scrollingEnabled: false)
                }
            }
            .navigationTitle("HTML in SwiftUI")
        }
    }

    var attributedStringBasedOnOptions: NSAttributedString {
        switch (renderLongHTML, renderRichHTML) {
        case (true, true):
            return attributedStrings.richLongHTML
        case (true, false):
            return attributedStrings.simpleLongHTML
        case (false, true):
            return attributedStrings.richHTML
        case (false, false):
            return attributedStrings.simpleHTML
        }
    }
}

// MARK: Previews

#Preview {
    ContentView()
}
