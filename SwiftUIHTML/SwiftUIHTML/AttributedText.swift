//
//  AttributedText.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 09/07/2023.
//

import SwiftUI

struct AttributedText: UIViewRepresentable {
    private let attributedString: NSAttributedString
    private let scrollingEnabled: Bool

    @available(iOS, deprecated: 16)
    init(
        _ attributedString: NSAttributedString,
        scrollingEnabled: Bool = true
    ) {
        self.attributedString = attributedString
        self.scrollingEnabled = scrollingEnabled
    }

    init(
        _ attributedString: NSAttributedString
    ) {
        self.attributedString = attributedString
        self.scrollingEnabled = true
    }

    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()

        // Make it transparent so that background Views can shine through.
        uiTextView.backgroundColor = .clear

        // For text visualization only, no editing.
        uiTextView.isEditable = false

        // Disabling scrolling will make the UITextView set its `intrinsicContentSize` to match its text content.
        if #available(iOS 16.0, *) {
            uiTextView.isScrollEnabled = context.environment.isScrollEnabled && scrollingEnabled
        } else {
            uiTextView.isScrollEnabled = scrollingEnabled
        }

        // Make UITextView flex to available width, but prefer height to fit to its content.
        uiTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
        uiTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiTextView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        uiTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return uiTextView
    }

    func updateUIView(_ uiTextView: UITextView, context: Context) {
        uiTextView.attributedText = attributedString

        // Disabling scrolling will make the UITextView set its `intrinsicContentSize` to match its text content.
        if #available(iOS 16.0, *) {
            uiTextView.isScrollEnabled = context.environment.isScrollEnabled && scrollingEnabled
        } else {
            uiTextView.isScrollEnabled = scrollingEnabled
        }
    }

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView uiTextView: UITextView, context: Context) -> CGSize? {
        // Calculate a fitting size if height or width is undefined/infinite.
        if let width = proposal.width, (proposal.height == nil || proposal.height == .infinity) {
            let proposedSize = CGSize(
                width: width,
                height: .infinity
            )

            let fittingSize = uiTextView.systemLayoutSizeFitting(
                proposedSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

            return CGSize(width: proposedSize.width, height: fittingSize.height)
        } else if let height = proposal.height, (proposal.width == nil || proposal.width == .infinity) {
            let proposedSize = CGSize(
                width: .infinity,
                height: height
            )

            let fittingSize = uiTextView.systemLayoutSizeFitting(
                proposedSize,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .required
            )

            return CGSize(width: fittingSize.width, height: proposedSize.height)
        } else {
            return nil // Default behavior.
        }
    }
}

// MARK: Previews

#Preview("VStack with multiple AttributedText") {
    VStack {
        AttributedText(PreviewValues.pureText)
        AttributedText(PreviewValues.longLoremIpsumText)
        AttributedText(PreviewValues.markdown)
        AttributedText(PreviewValues.longLoremIpsumMarkdown)
        AttributedText(PreviewValues.html)
        AttributedText(PreviewValues.longLoremIpsumHTML)
        AttributedText(PreviewValues.htmlDocument)
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("VStack with long AttributedText") {
    VStack {
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("HStack with multiple AttributedText") {
    HStack {
        AttributedText(PreviewValues.pureText)
        AttributedText(PreviewValues.longLoremIpsumText)
        AttributedText(PreviewValues.markdown)
        AttributedText(PreviewValues.longLoremIpsumMarkdown)
        AttributedText(PreviewValues.html)
        AttributedText(PreviewValues.longLoremIpsumHTML)
        AttributedText(PreviewValues.htmlDocument)
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("HStack with long AttributedText") {
    HStack {
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("ZStack with multiple AttributedText") {
    ZStack {
        AttributedText(PreviewValues.pureText)
        AttributedText(PreviewValues.longLoremIpsumText)
        AttributedText(PreviewValues.markdown)
        AttributedText(PreviewValues.longLoremIpsumMarkdown)
        AttributedText(PreviewValues.html)
        AttributedText(PreviewValues.longLoremIpsumHTML)
        AttributedText(PreviewValues.htmlDocument)
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("ZStack with long AttributedText") {
    ZStack {
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("ScrollView with multiple AttributedText") {
    ScrollView {
        AttributedText(PreviewValues.pureText)
        AttributedText(PreviewValues.longLoremIpsumText)
        AttributedText(PreviewValues.markdown)
        AttributedText(PreviewValues.longLoremIpsumMarkdown)
        AttributedText(PreviewValues.html)
        AttributedText(PreviewValues.longLoremIpsumHTML)
        AttributedText(PreviewValues.htmlDocument)
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("ScrollView with long AttributedText") {
    ScrollView {
        AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
    }
}

#Preview("ScrollView with multiple AttributedText (scrolling disabled)") {
    ScrollView {
        if #available(iOS 16.0, *) {
            Group {
                AttributedText(PreviewValues.pureText)
                AttributedText(PreviewValues.longLoremIpsumText)
                AttributedText(PreviewValues.markdown)
                AttributedText(PreviewValues.longLoremIpsumMarkdown)
                AttributedText(PreviewValues.html)
                AttributedText(PreviewValues.longLoremIpsumHTML)
                AttributedText(PreviewValues.htmlDocument)
                AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
            }
            .scrollDisabled(true)
        } else {
            AttributedText(PreviewValues.pureText, scrollingEnabled: false)
            AttributedText(PreviewValues.longLoremIpsumText, scrollingEnabled: false)
            AttributedText(PreviewValues.markdown, scrollingEnabled: false)
            AttributedText(PreviewValues.longLoremIpsumMarkdown, scrollingEnabled: false)
            AttributedText(PreviewValues.html, scrollingEnabled: false)
            AttributedText(PreviewValues.longLoremIpsumHTML, scrollingEnabled: false)
            AttributedText(PreviewValues.htmlDocument, scrollingEnabled: false)
            AttributedText(PreviewValues.longLoremIpsumHTMLDocument, scrollingEnabled: false)
        }
    }
}

#Preview("ScrollView with long AttributedText (scrolling disabled)") {
    ScrollView {
        if #available(iOS 16.0, *) {
            AttributedText(PreviewValues.longLoremIpsumHTMLDocument)
                .scrollDisabled(true)
        } else {
            AttributedText(PreviewValues.longLoremIpsumHTMLDocument, scrollingEnabled: false)
        }
    }
}

private enum PreviewValues {
    @MainActor static let pureText = NSAttributedString(
        string: "Some pure text"
    )

    @MainActor static let longLoremIpsumText = NSAttributedString(string: """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.
        
        Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.
        
        Nam in mattis nibh, in iaculis sapien. Donec vitae convallis metus, quis lobortis purus. Nulla vestibulum dignissim aliquam. Nullam varius erat nec scelerisque faucibus. Duis porttitor lacinia bibendum. Aliquam placerat vitae nulla ut gravida. Donec ac eros placerat, tempor quam quis, pellentesque ex. Sed porttitor lorem ut dolor ultrices, vel scelerisque ipsum maximus. Aliquam id erat id metus mattis sollicitudin eu sit amet velit. Maecenas eget massa scelerisque, feugiat est sit amet, cursus lorem. Praesent risus libero, lobortis vitae molestie at, pretium sed nibh.
        
        Donec pretium nibh sapien, vel egestas libero aliquam et. Aenean id tincidunt lectus. Donec scelerisque nunc consequat nunc molestie, ut cursus metus ornare. Sed ullamcorper, orci id pellentesque facilisis, odio eros volutpat ligula, in bibendum tortor lorem vitae dolor. Suspendisse mollis nibh ligula, quis faucibus tortor porta sed. Mauris odio arcu, luctus at ipsum quis, pulvinar volutpat nisl. Integer sollicitudin imperdiet erat, nec interdum sem placerat nec. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
        
        Maecenas eros ligula, rhoncus sit amet pulvinar in, rutrum sit amet eros. Maecenas aliquam, felis vitae condimentum accumsan, leo arcu consequat est, sed gravida diam risus a est. Vivamus odio quam, viverra quis facilisis eget, pulvinar id tortor. Donec id lacus egestas lacus condimentum malesuada nec a orci. Integer felis diam, molestie eu suscipit vel, dictum a ex. Fusce sit amet elementum arcu, at pulvinar felis. Cras id erat odio. Phasellus non ante facilisis, sollicitudin lectus vitae, aliquet lacus.
        """)

    @MainActor static let markdown = (try? NSAttributedString(
        markdown: """
        _Header_
        - List item one
        - List item two
        """
    )) ?? NSAttributedString(string: "")

    @MainActor static let longLoremIpsumMarkdown = (try? NSAttributedString(
        markdown: """
        _Header_
        - Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.
        - Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.
        - Nam in mattis nibh, in iaculis sapien. Donec vitae convallis metus, quis lobortis purus. Nulla vestibulum dignissim aliquam. Nullam varius erat nec scelerisque faucibus. Duis porttitor lacinia bibendum. Aliquam placerat vitae nulla ut gravida. Donec ac eros placerat, tempor quam quis, pellentesque ex. Sed porttitor lorem ut dolor ultrices, vel scelerisque ipsum maximus. Aliquam id erat id metus mattis sollicitudin eu sit amet velit. Maecenas eget massa scelerisque, feugiat est sit amet, cursus lorem. Praesent risus libero, lobortis vitae molestie at, pretium sed nibh.
        - Donec pretium nibh sapien, vel egestas libero aliquam et. Aenean id tincidunt lectus. Donec scelerisque nunc consequat nunc molestie, ut cursus metus ornare. Sed ullamcorper, orci id pellentesque facilisis, odio eros volutpat ligula, in bibendum tortor lorem vitae dolor. Suspendisse mollis nibh ligula, quis faucibus tortor porta sed. Mauris odio arcu, luctus at ipsum quis, pulvinar volutpat nisl. Integer sollicitudin imperdiet erat, nec interdum sem placerat nec. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
        - Maecenas eros ligula, rhoncus sit amet pulvinar in, rutrum sit amet eros. Maecenas aliquam, felis vitae condimentum accumsan, leo arcu consequat est, sed gravida diam risus a est. Vivamus odio quam, viverra quis facilisis eget, pulvinar id tortor. Donec id lacus egestas lacus condimentum malesuada nec a orci. Integer felis diam, molestie eu suscipit vel, dictum a ex. Fusce sit amet elementum arcu, at pulvinar felis. Cras id erat odio. Phasellus non ante facilisis, sollicitudin lectus vitae, aliquet lacus.
        """
    )) ?? NSAttributedString(string: "")

    @MainActor static let html = (try? NSAttributedString(
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

    @MainActor static let longLoremIpsumHTML = (try? NSAttributedString(
        data: """
        <p>This is a paragraph</p>
        <ul>
            <li>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.</li>
            <li>Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.</li>
            <li>Nam in mattis nibh, in iaculis sapien. Donec vitae convallis metus, quis lobortis purus. Nulla vestibulum dignissim aliquam. Nullam varius erat nec scelerisque faucibus. Duis porttitor lacinia bibendum. Aliquam placerat vitae nulla ut gravida. Donec ac eros placerat, tempor quam quis, pellentesque ex. Sed porttitor lorem ut dolor ultrices, vel scelerisque ipsum maximus. Aliquam id erat id metus mattis sollicitudin eu sit amet velit. Maecenas eget massa scelerisque, feugiat est sit amet, cursus lorem. Praesent risus libero, lobortis vitae molestie at, pretium sed nibh.</li>
            <li>Donec pretium nibh sapien, vel egestas libero aliquam et. Aenean id tincidunt lectus. Donec scelerisque nunc consequat nunc molestie, ut cursus metus ornare. Sed ullamcorper, orci id pellentesque facilisis, odio eros volutpat ligula, in bibendum tortor lorem vitae dolor. Suspendisse mollis nibh ligula, quis faucibus tortor porta sed. Mauris odio arcu, luctus at ipsum quis, pulvinar volutpat nisl. Integer sollicitudin imperdiet erat, nec interdum sem placerat nec. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</li>
            <li>Maecenas eros ligula, rhoncus sit amet pulvinar in, rutrum sit amet eros. Maecenas aliquam, felis vitae condimentum accumsan, leo arcu consequat est, sed gravida diam risus a est. Vivamus odio quam, viverra quis facilisis eget, pulvinar id tortor. Donec id lacus egestas lacus condimentum malesuada nec a orci. Integer felis diam, molestie eu suscipit vel, dictum a ex. Fusce sit amet elementum arcu, at pulvinar felis. Cras id erat odio. Phasellus non ante facilisis, sollicitudin lectus vitae, aliquet lacus.</li>
        </ul>
        <p>This is another paragraph</p>
        """.data(using: .utf8)!,
        options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: NSUTF8StringEncoding,
        ],
        documentAttributes: nil
    )) ?? NSAttributedString(string: "")

    @MainActor static let htmlDocument = (try? NSAttributedString(
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

    @MainActor static let longLoremIpsumHTMLDocument = (try? NSAttributedString(
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
                <li>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In et orci sit amet nibh convallis commodo hendrerit ut dui. Maecenas hendrerit enim non lorem condimentum sagittis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam pretium, dui id vestibulum congue, ante metus consectetur metus, et commodo velit arcu quis justo. Sed varius orci quis metus mollis condimentum. Nulla malesuada ex hendrerit, dapibus nisi nec, mattis erat. Morbi luctus mollis nunc, eu fringilla arcu aliquet at. Praesent laoreet vel nunc sed tincidunt. Phasellus tristique tincidunt dapibus. Donec et ante lobortis, sodales ex vitae, sagittis nulla. Sed tempor scelerisque elementum. Donec congue sem vitae blandit laoreet. Aliquam bibendum justo purus. Aliquam nulla nibh, laoreet sed egestas et, lacinia eu diam.</li>
                <li>Sed imperdiet tristique auctor. Nulla ornare cursus finibus. Ut sagittis est augue, bibendum consequat nulla fermentum vitae. Donec laoreet, ex sed pretium tempor, metus dolor consectetur ante, nec tincidunt dui ante ac lectus. In semper ante in nunc ornare molestie. Pellentesque sit amet metus id enim porttitor tincidunt ut sed eros. Morbi suscipit sapien arcu, eget sodales mauris elementum vitae. Cras eu dui ac diam aliquam vestibulum sed et massa. Fusce rutrum tellus massa, quis egestas elit pellentesque sed. Vestibulum dignissim nibh tellus, luctus vulputate leo rutrum ut. Fusce gravida est ac elit consequat accumsan. Phasellus a turpis arcu.</li>
                <li>Nam in mattis nibh, in iaculis sapien. Donec vitae convallis metus, quis lobortis purus. Nulla vestibulum dignissim aliquam. Nullam varius erat nec scelerisque faucibus. Duis porttitor lacinia bibendum. Aliquam placerat vitae nulla ut gravida. Donec ac eros placerat, tempor quam quis, pellentesque ex. Sed porttitor lorem ut dolor ultrices, vel scelerisque ipsum maximus. Aliquam id erat id metus mattis sollicitudin eu sit amet velit. Maecenas eget massa scelerisque, feugiat est sit amet, cursus lorem. Praesent risus libero, lobortis vitae molestie at, pretium sed nibh.</li>
                <li>Donec pretium nibh sapien, vel egestas libero aliquam et. Aenean id tincidunt lectus. Donec scelerisque nunc consequat nunc molestie, ut cursus metus ornare. Sed ullamcorper, orci id pellentesque facilisis, odio eros volutpat ligula, in bibendum tortor lorem vitae dolor. Suspendisse mollis nibh ligula, quis faucibus tortor porta sed. Mauris odio arcu, luctus at ipsum quis, pulvinar volutpat nisl. Integer sollicitudin imperdiet erat, nec interdum sem placerat nec. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</li>
                <li>Maecenas eros ligula, rhoncus sit amet pulvinar in, rutrum sit amet eros. Maecenas aliquam, felis vitae condimentum accumsan, leo arcu consequat est, sed gravida diam risus a est. Vivamus odio quam, viverra quis facilisis eget, pulvinar id tortor. Donec id lacus egestas lacus condimentum malesuada nec a orci. Integer felis diam, molestie eu suscipit vel, dictum a ex. Fusce sit amet elementum arcu, at pulvinar felis. Cras id erat odio. Phasellus non ante facilisis, sollicitudin lectus vitae, aliquet lacus.</li>
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
}
