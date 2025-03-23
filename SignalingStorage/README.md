# Observable and Signaling Keychain and Defaults Storage

This example application showcase a couple of ways to make an "Observable" abstraction around [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) and [the Keychain](https://developer.apple.com/documentation/security/keychain-services).
Making it possible to be notified in one part of the app when another part of the app changes a value stored in `UserDefaults` or the `Keychain`.

- **ObservableDefaults:** An abstraction around `UserDefaults` that implement `ObservableObject`. Will publish change events whenever any value changes.
- **SignalingDefaults:** An abstraction around `UserDefaults` that signals whenever a given value change. The benefit of `SignalingDefaults` over `ObservableDefaults` is that `SignalingDefaults` only signal changes on a per value basis.
- **ObservableKeychain:** An abstraction around the `Keychain` that implement `ObservableObject`. Will publish change events whenever any value changes.
- **SignalingKeychain:** An abstraction around the `Keychain` signals whenever a given value change. The benefit of `SignalingKeychain` over `ObservableKeychain` is that `SignalingKeychain` only signal changes on a per value basis.
