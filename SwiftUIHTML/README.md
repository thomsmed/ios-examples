# Render HTML in SwiftUI

Example on how to render HTML in SwiftUI using UITextView wrapped in a UIViewRepresentable.

Check out [Render HTML in SwiftUI](https://medium.com/@thomsmed/rendering-html-in-swiftui-65e883a63571) for a writeup @ Medium.

Some takeaways after working with this example:
Keep your View's body as lightweight as possible. Avoid doing heavy computations and/or object instantiations inside a View's body property. This slows down SwiftUI and might produce odd/unexpected behavior.

Useful resources:
- [Integrating SwiftUI](https://developer.apple.com/wwdc19/231)
- [Demystify SwiftUI](https://developer.apple.com/wwdc21/10022)
- [Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
