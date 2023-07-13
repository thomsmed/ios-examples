//
//  NSAttributedString+themedHtml.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 13/07/2023.
//

import UIKit

/// Convenience extension to use with ``AttributedText``.
extension NSAttributedString {
    static func themedHtml(withBody body: String, theme: Theme = .default) -> NSAttributedString {
        // Match the HTML `lang` attribute to current localisation used by the app (aka Bundle.main).
        let bundle = Bundle.main
        let lang = bundle.preferredLocalizations.first
            ?? bundle.developmentLocalization
            ?? "en"

        return (try? NSAttributedString(
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
                        color: \(theme.textSecondary.hex);
                    }

                    h1, h2, h3, h4, h5, h6 {
                        color: \(theme.textPrimary.hex);
                    }

                    a {
                        color: \(theme.textInteractive.hex);
                    }

                    li:last-child {
                        margin-bottom: 1em;
                    }
                </style>
            </head>
            <body>
                \(body)
            </body>
            </html>
            """.data(using: .utf8)!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: NSUTF8StringEncoding,
            ],
            documentAttributes: nil
        )) ?? NSAttributedString(string: body)
    }
}

