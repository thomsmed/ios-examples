//
//  HTML.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct HTML: View {
    private let bodyText: String

    init(_ bodyText: String) {
        self.bodyText = bodyText
    }

    public var body: some View {
        // Match the HTML `lang` attribute to current localisation used by the app (aka Bundle.main).
        let bundle = Bundle.main
        let lang = bundle.preferredLocalizations.first
            ?? bundle.developmentLocalization
            ?? "en"

        AttributedText((try? NSAttributedString(
            data: """
            <!doctype html>
            <html lang="\(lang)">
            <head>
                <meta charset="utf-8">
                <style type="text/css">
                    /*
                      Custom CSS styling of HTML formatted text.
                      Note, only a limited number of CSS features are supported by NSAttributedString/UITextView.
                    */

                    body {
                        font: -apple-system-body;
                        color: \(UIColor.secondaryLabel.hex);
                    }

                    h1, h2, h3, h4, h5, h6 {
                        color: \(UIColor.label.hex);
                    }

                    a {
                        color: \(UIColor.systemGreen.hex);
                    }

                    li:last-child {
                        margin-bottom: 1em;
                    }
                </style>
            </head>
            <body>
                \(bodyText)
            </body>
            </html>
            """.data(using: .utf8)!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: NSUTF8StringEncoding,
            ],
            documentAttributes: nil
        )) ?? NSAttributedString(string: bodyText))
    }
}

// MARK: Previews

struct HTML_Previews: PreviewProvider {
    private static let pureText = """
        Some pure text
        """

    private static let simpleHTML = """
        <p>This is a paragraph</p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
        </ul>
        """

    private static let richHTML = """
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
        """

    static var previews: some View {
        HTML(Self.pureText)
        HTML(Self.simpleHTML)
        HTML(Self.richHTML)
    }
}
