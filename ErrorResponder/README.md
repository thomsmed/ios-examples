# Error Responder Chain

Heavily inspired by the concept of a [Responder Chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events), this example project illustrate how that same concept can be applied to handling errors in an app.

## The ErrorResponder protocol

```swift
public enum ErrorEvaluation: Sendable {
    /// Necessary actions has been taken in response to the ``Error``.
    /// Proceed in whatever way that is natural.
    case proceed

    /// Necessary actions has been taken in response to the ``Error``.
    /// Cancel any succeeding actions, and stay put.
    case cancel

    /// Necessary actions has been taken in response to the ``Error``.
    /// Retry whatever action caused the ``Error`` to occur.
    case retry

    /// Necessary actions has been taken in response to the ``Error``.
    /// Abort whatever flow/process caused this ``Error``, as the ``Error`` was too severe to let the flow continue.
    case abort
}

public protocol ErrorResponder: AnyObject {
    var parent: (any ErrorResponder)? { get set }

    func respond(to error: any Error) async -> ErrorEvaluation
}
```

However how you manage navigation in your application, "branching points" can implement this protocol to both handle Errors and pass them along further up the "chain". Wether you manager navigation purely in SwiftUI, UIKit or using a pattern like Coordinators.

This project includes an example using SwiftUI, but can easily be adopted in UIKit applications as well.

One could imagine various ErrorResponder chains:

- ErrorResponder chain in a pure SwiftUI app, where ViewModels form the chain.
- ErrorResponder chain in a pure UIKit app, where ViewModels and Coordinators form the chain.
- ErrorResponder chain in a pure UIKit app, where UIViewControllers form the chain.
- ErrorResponder chain in a mixed UIKit and SwiftUI app, where ViewModels, Services, Coordinators and the AppDelegate form the chain.
- ErrorResponder chain in a mixed UIKit and SwiftUI app, where the AppDelegate and UIViewControllers form the chain.
