# Vertical Slice Architecture (and Domain Driven Design)

Highly inspired by several ideas over at https://www.objc.io/ (introduced to me by one of my colleagues, Audun. Thanks!),
this example application aims to show how to work more with Swift types directly instead of through layers of abstractions (e.g ViewModels, Services, Repositories etc).

The basic idea is that we only have a handful of actual dependencies (A "thing" that knows how to store stuff in the keychain,
a "thing" that knows how to store stuff in a database,
a "thing" that knows how to do network request etc),
and have our types/domain models implement traits/protocols to be able to interact/work with these dependencies.
We create types for almost everything, and leverage protocols like Swift's [RawRepresentable](https://developer.apple.com/documentation/swift/rawrepresentable).

In other words; we try to write more idiomatic Swift:

- Leverage Swift's type system to the fullest. Make Swift help us write safe and correct code.
  - Buzz words: Generics, Protocol Oriented Programming, Phantom Types.
- Un-mutable over mutable.
- Value types over reference types.
- Composition (protocols and extension) over inheritance (subclassing).
- Write business logic that prefers immutability and avoid side effects.
  - Try to only mutate and trigger side effects (storing data, networking, etc) outside domain models and logic.

## Feature Slices

An architecture pattern that fits nicely with this way of thinking/writing code,
is [Vertical Slice Architecture](https://www.jimmybogard.com/vertical-slice-architecture/) (coined by Jimmy Bogard).
Where we think in vertical slices with our domain models and business logic in the middle,
and UI (SwiftUI/UIKit) and IO (Networking, Database, Keychain etc) at the top and bottom.

In a SwiftUI app, Views act as the "glue" around our vertical slices.
And dependencies are typically injected into our Views in some way (e.g using the SwiftUI Environment).
User interaction (e.g user tapping a button) represent the entry point into a vertical slice (from the top).

In a UIKit app, ViewControllers act as the "glue" around our vertical slices.
And dependencies are typically injected into our ViewControllers in some way.

Moving around and refactoring code should be encouraged,
to make sure the project folder structure reflect how features are laid out in the app (vertical slices).

The general idea:

- App - iOS app specific stuff (e.g AppDelegate, AppIntents, FeatureToggleStorage).
- Common - App wide shared dependencies. Should be kept to a bare minimum! (e.g DefaultsStorage, SecureStorage, CryptographicKeyStorage, HTTPClient, DatabaseClient).
- Domain - App wide domain models. Types that directly reflect the primary/overall business domain of the app. (e.g User, UserName, AccessToken).
- Features
  - Top level feature one
    - Common - Per feature slice shared dependencies. Should be kept to a bare minimum!
    - Domain - Per feature slice domain models. Reflects a particular feature's business domain.
    - Sub level feature one
      - Common
      - Domain
      - ...
  - Top level feature two
    - Sub level feature one
      - Common
      - Domain
      - ...
    - Sub level feature two
      - Common
      - Domain
      - ...
  - ...

### App wide shared dependencies

- [DefaultsStorage](VerticalSlices/Common/DefaultsStorage) - knows how to manage types adopting `DefaultsStorable` and `UniqueDefaultsStorable`.
- [SecureStorage](VerticalSlices/Common/SecureStorage) - knows how to manage types adopting `SecurelyStorable` and `UniqueSecurelyStorable`.
- [CryptographicKeyStorage](VerticalSlices/Common/CryptographicKeyStorage) - knows how to manage types adopting `ManagedCryptographicKey` and `UniqueManagedCryptographicKey`.
- [HTTPClient](VerticalSlices/Common/EnvironmentValues+HTTPClient) - knows how to do HTTP requests based on instances of `Endpoint`. Check out [HTTPSwift](https://github.com/thomsmed/http-swift).
- [DatabaseClient](VerticalSlices/Common/EnvironmentValues+DatabaseClient) - knows how to do (SQLite) database queries based on instances of `DatabaseEntity`. Check out [GRDB.swift](https://github.com/groue/GRDB.swift).

### Dependency Injection

Dependency Injection (and the dependency inversion principle) is awesome,
both for making code more maintainable and loosely coupled,
but also to better facilitate for Unit and Integration tests.

If you can get away with just using the SwiftUI Environment or a simple custom "Dependency Container",
that's perfect! Otherwise, there are awesome libraries out there that can make your life easier.

Check out [App Dependencies](https://github.com/thomsmed/app-dependencies-swift) for inspiration!

> NOTE: Just remember to keep the number of app wide shared dependencies to a bare minimum!
