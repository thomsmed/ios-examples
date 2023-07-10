//
//  AttributedText.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct AttributedText: UIViewRepresentable {
    private let attributedString: NSAttributedString

    init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()

        // Make it transparent so that background Views can shine through.
        uiTextView.backgroundColor = .clear

        // For text visualisation only, no editing.
        uiTextView.isEditable = false

        // Make UITextView flex to available width, but require height to fit its content.
        // Also disable scrolling so the UITextView will set its `intrinsicContentSize` to match its text content.
        uiTextView.isScrollEnabled = false
        uiTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
        uiTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        uiTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return uiTextView
    }

    func updateUIView(_ uiTextView: UITextView, context: Context) {
        uiTextView.attributedText = attributedString
        print("intrinsicContentSize:", uiTextView.intrinsicContentSize)
    }
}

// MARK: Previews

struct AttributedText_Previews: PreviewProvider {
    private static let pureText = NSAttributedString(
        string: "Some pure text"
    )

    private static let markdown = (try? NSAttributedString(
        markdown: """
        _Header_
        - List item one
        - List item two
        """
    )) ?? NSAttributedString(string: "")

    private static let html = (try? NSAttributedString(
        data: """
        <p>This is a paragraph</p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
        </ul>
        <p>This is another paragraph</p>
        """.data(using: .utf8)!,
        options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: NSUTF8StringEncoding,
        ],
        documentAttributes: nil
    )) ?? NSAttributedString(string: "")

    private static let htmlDocument = (try? NSAttributedString(
        data: """
        <!doctype html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <style>
                body { font: -apple-system-body; }
                p { color: red; }
                li { color: green; }
                li:last-child { color: orange; margin-bottom: 1em; }
            </style>
        </head>
        <body>
            <p>This is a paragraph</p>
            <ul>
                <li>List item one</li>
                <li>List item two</li>
            </ul>
            <p>This is another paragraph</p>
        </body>
        </html>
        """.data(using: .utf8)!,
        options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: NSUTF8StringEncoding,
        ],
        documentAttributes: nil
    )) ?? NSAttributedString(string: "")

    static var previews: some View {
        VStack {
            AttributedText(Self.pureText)
            AttributedText(Self.markdown)
            AttributedText(Self.html)
            AttributedText(Self.htmlDocument)
        }
    }
}
