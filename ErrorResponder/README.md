# Error Responder Chain

Heavily inspired by the concept of a [Responder Chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events), this example project illustrate how that same concept can be applied to handling errors in an app.

The `respondToError` SwiftUI Environment value is also greatly inspired by how SwiftUI's [OpenURLAction](https://developer.apple.com/documentation/swiftui/environmentvalues/openurl) works.

## The ErrorResponder protocol and SwiftUI Environment value

```swift
import Foundation
import SwiftUI

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

@MainActor public protocol ErrorResponder: AnyObject {
    var parentResponder: (any ErrorResponder)? { get set }

    @discardableResult
    func respond(to error: any Error) async -> ErrorEvaluation
}

@MainActor public struct RespondToErrorAction {
    let respondToError: (any Error) async -> ErrorEvaluation

    @discardableResult
    func callAsFunction(_ error: any Error) async -> ErrorEvaluation {
        return await respondToError(error)
    }
}

public struct RespondToErrorActionEnvironmentKey: EnvironmentKey {
    public static let defaultValue: RespondToErrorAction = RespondToErrorAction { _ in
        assertionFailure("Unhandled error")
        return .proceed
    }
}

public extension EnvironmentValues {
    var respondToError: RespondToErrorAction {
        get { self[RespondToErrorActionEnvironmentKey.self] }
        set { self[RespondToErrorActionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func respondToError(_ respondToError: @escaping (any Error) async -> ErrorEvaluation) -> some View {
        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
    }
}
```

However how you manage navigation in your application, "branching points" can implement the ErrorResponder protocol (or use/set the `respondToError` SwiftUI Environment value) to both handle Errors and pass them along further up the "chain".
Wether you manage navigation purely in SwiftUI, UIKit or using a pattern like Coordinators.

This project includes an example using SwiftUI with ViewModels, but can easily be adopted in UIKit applications as well.

One could easily imagine various ErrorResponder chains:

- ErrorResponder chain in a pure SwiftUI app, where ViewModels form the chain. All adopting the ErrorResponder protocol.
- ErrorResponder chain in a pure SwiftUI app, where Views form the chain. All using and/or setting the `respondToError` SwiftUI Environment value.
- ErrorResponder chain in a pure UIKit app, where ViewModels and Coordinators form the chain. All adopting the ErrorResponder protocol.
- ErrorResponder chain in a pure UIKit app, where UIViewControllers form the chain. All adopting the ErrorResponder protocol.
- ErrorResponder chain in a mixed UIKit and SwiftUI app, where the chain is formed by Views and `UIViewControllers`. SwiftUI Views use and/or set the `respondToError` SwiftUI Environment value, while `UIHostingControllers` form a bridge between UIKit and SwiftUI by adopting the ErrorResponder protocol and setting the `respondToError` SwiftUI Environment value of their `rootView`.
- ErrorResponder chain in a mixed UIKit and SwiftUI app, where ViewModels, Services, Coordinators and the AppDelegate form the chain. All adopting the ErrorResponder protocol.

### Simple pure SwiftUI example

```swift
enum MyError: Error, CaseIterable {
    case homePageError
    case homeTabError
    case rootError
    case appError

    static var random: MyError {
        MyError.allCases[Int.random(in: 0..<Self.allCases.count)]
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .respondToError { error in
                    switch error {
                        case MyError.appError:
                            print("Error handled at App level")
                            return .proceed
                        default:
                            assertionFailure("Unhandled error")
                            return .proceed
                    }
                }
        }
    }
}

struct RootView: View {
    @Environment(\.respondToError) private var respondToError

    var body: some View {
        TabView {
            Tab {
                HomeTabView()
            }
        }
        .respondToError { error in
            switch error {
                case MyError.rootError:
                    print("Error handled at Root level")
                    return .proceed
                default:
                    return await respondToError(error)

            }
        }
    }
}

struct HomeTabView: View {
    @Environment(\.respondToError) private var respondToError

    var body: some View {
        NavigationStack {
            HomePageView()
        }
        .respondToError { error in
            switch error {
                case MyError.homeTabError:
                    print("Error handled at Home Tab level")
                    return .proceed
                default:
                    return await respondToError(error)

            }
        }
    }
}

struct HomePageView: View {
    @Environment(\.respondToError) private var respondToError

    var body: some View {
        HomeScreenContentView()
            .respondToError { error in
                switch error {
                    case MyError.homePageError:
                        print("Error handled at Home Page level")
                        return .proceed
                    default:
                        return await respondToError(error)

                }
            }
    }
}

struct HomeScreenContentView: View {
    @Environment(\.respondToError) private var respondToError

    var body: some View {
        VStack {
            Text("Home")
                .padding()

            Button("Trigger error", action: didTapButton)
                .padding()
        }
    }

    private func didTapButton() {
        Task {
            do {
                try await Task.sleep(for: .milliseconds(100)) // Simulate networking

                throw MyError.random
            } catch {
                print("Error triggered in Home Screen Content")

                switch await respondToError(error) {
                    case .retry:
                        didTapButton()
                    default:
                        break
                }
            }
        }
    }
}
```

### Bridging from SwiftUI to UIKit

```swift
final class RootNavigationController: UINavigationController, ErrorResponder {
    public weak var parentResponder: (any ErrorResponder)? = nil

    public init(parentResponder: (any ErrorResponder)? = nil) {
        self.parentResponder = parentResponder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func respond(to error: any Error) async -> ErrorEvaluation {
        guard let parentResponder else {
            assertionFailure("Unhandled error in ErrorResponder chain")
            return .abort
        }

        return await parentResponder.respond(to: error)
    }

    // MARK: Push and present hosted SwiftUI Views

    private func pushAPage() {
        let view = ScrollView {
            Text("Hello there!")
        }.respondToError { [weak self] error in
            if true {
                print("Error handled at Root Navigation level")
                return .proceed
            } else {
                return await self?.parentResponder?.respond(to: error) ?? .proceed
            }
        }

        let hostingController = UIHostingController(rootView: view)

        pushViewController(hostingController, animated: true)
    }

    private func presentAPage() {
        let view = NavigationStack {
            VStack {
                Text("Hello there!")
            }
        }.respondToError { [weak self] error in
            if true {
                print("Error handled at Root Navigation level")
                return .proceed
            } else {
                return await self?.parentResponder?.respond(to: error) ?? .proceed
            }
        }

        let hostingController = UIHostingController(rootView: view)

        present(hostingController, animated: true)
    }
}
```

## The ErrorResponderChain class

As an alternative to (or in addition to) the ErrorResponderProtocol, one could imagine an `ErrorResponderChain` class to provide the same power.

```swift
/// Convenience type that by it self represent an Error Responder Chain.
/// Could be used standalone to combine the error handling in any arbitrary components,
/// but could also act as a bridge between the View layer (SwiftUI / UIKit with ViewModels) and any other part of the app.
/// E.g services or anything that just want to connect to the Error Responder chain (permanently or temporarily).
///
/// Error Responders are added to the front of the chain, hence the last responder to register is the first to (potentially) handle new Errors.
@MainActor public final class ErrorResponderChain: ErrorResponder {
    private var errorResponders: [(uuid: UUID, respondTo: (any Error) async -> ErrorEvaluation?)] = []

    public var parentResponder: (any ErrorResponder)? = nil

    init(parentResponder: (any ErrorResponder)? = nil) {
        self.parentResponder = parentResponder
    }

    public func connect(_ respondTo: @escaping (any Error) async -> ErrorEvaluation?) -> UUID {
        let uuid = UUID()
        errorResponders.insert((uuid: uuid, respondTo: respondTo), at: 0)
        return uuid
    }

    public func disconnect(_ uuid: UUID) {
        errorResponders.removeAll(where: { $0.uuid == uuid })
    }

    public func respond(to error: any Error) async -> ErrorEvaluation {
        for errorResponder in errorResponders {
            if let evaluation = await errorResponder.respondTo(error) {
                return evaluation
            }
        }

        guard let parentResponder else {
            assertionFailure("Unhandled error")
            return .proceed
        }

        return await parentResponder.respond(to: error)
    }
}
```

Check out [BackgroundService.swift](ErrorResponder/App/BackgroundService.swift) and its usages for an example.
