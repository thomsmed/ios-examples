# Vertical Slice Architecture (and Domain Driven Design)

Highly inspired by several ideas over at https://www.objc.io/ (introduced to me by one of my colleagues, Audun. Thanks!),
this example application aims to show how one could work more with Swift types directly instead of through layers of abstractions (e.g ViewModels, Services, Repositories etc).

The basic idea is that we only have a handful of actual dependencies (A "thing" to store stuff in the keychain, a "thing" to store stuff in a database, a "thing" to do networking etc),
and have our types/domain models implement traits/protocols to be able to interact/work with these dependencies.
We create types for almost everything, and leverage protocols like Swift's [RawRepresentable](https://developer.apple.com/documentation/swift/rawrepresentable).

In other words; we try to write more idiomatic Swift:

- Leverage Swift's type system to the fullest. Make Swift help us write safe and correct code.
  - Buzz words: Generics, Protocol Oriented Programming, Phantom Types.
- Un-mutable over mutable.
- Value types over reference types.
- Composition (protocols and extension) over inheritance (subclassing).

## Feature Slices

An architecture pattern that fits nicely with this way of writing code,
is [Vertical Slice Architecture](https://www.jimmybogard.com/vertical-slice-architecture/) (coined by Jimmy Bogard).
Where we think in vertical slices with our domain models and business logic in the middle,
and UI (SwiftUI/UIKit) and IO (Networking, Database, Keychain etc) at the top and bottom.

In a SwiftUI app, Views act as the "glue" around our vertical slices.
And the SwiftUI Environment is used to make dependencies available to Views.
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

- [DefaultsStorage](VerticalSlices/Common/DefaultsStorage) - knows how to manage types adopting `DefaultsStorable`.
- [SecureStorage](VerticalSlices/Common/SecureStorage) - knows how to manage types adopting `SecurelyStorable` and `UniqueSecurelyStorable`.
- [CryptographicKeyStorage](VerticalSlices/Common/CryptographicKeyStorage) - knows how to manage types adopting `ManagedCryptographicKey`.
- [HTTPClient](VerticalSlices/Common/EnvironmentValues+HTTPClient) - knows how to do HTTP requests based on instances of `Endpoint`. Check out [HTTPSwift](https://github.com/thomsmed/http-swift).
- [DatabaseClient](VerticalSlices/Common/EnvironmentValues+DatabaseClient) - knows how to do (SQLite) database queries based on instances of `DatabaseEntity`. Check out [GRDB.swift](https://github.com/groue/GRDB.swift).
