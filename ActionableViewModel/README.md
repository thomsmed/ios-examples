# Action emitting ViewModels and Coordinator Views

A simple architecture/design pattern for managing navigation and routing in SwiftUI applications.

## The Actionable protocol

A simple protocol representing types that emit actions. Typically ViewModels or Coordinator Views that emit actions after user interaction (e.g button tap), completed async work (e.g network request) or as a result of a completed (or partially completed) user flow/journey.

## Coordinator Views

- Views hosting and managing navigation container views, like TabView and NavigationStack.
- Typically also responsible for presenting content as sheets or full-screen pages.
- With ViewModels that are Actionable and emit actions as a result of a completed (or partially completed) user flow/journey.

> In a pure UIKit application (or hybrid SwiftUI / UIKit application) Coordinator Views can simply be replaced with Coordinators. In that case, Coordinators would then be Action emitting Coordinators and implement the Actionable protocol.

## Action emitting ViewModels

- ViewModels that emit actions after user interactions (e.g button tap) or async work (e.g network request).
