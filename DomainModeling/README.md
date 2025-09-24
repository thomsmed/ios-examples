# Domain Modeling

Domain Modeling is all about representing domain knowledge in code,
utilizing the programming language at hand.

Sources of inspiration:

- Point-Free's [Tagged](https://github.com/pointfreeco/swift-tagged).

## Types and attributes

Things to explore:

- Expressions and statements
    - Statements produce side effects (changes the state of the system)
    - Expressions produce value(s)
    - Functional core, imperative shell
        - Core/business logic should be mostly expressions (and immutable data)
        - I/O (e.g UI, storage, networking) is all about statements
- Immutability
- Composition over inheritance (avoiding subclassing!)
    - Think systems, not abstractions (e.g Entity Component System)
        - UI system (SwiftUI and Views)
        - Networking system (URLSession and Endpoints)
        - Storage system (Database and Queries)
    - Avoid protocols - use functions and structs instead
- Type system
    - Functions
    - Union types
    - Records (aka structs)
    - Phantom types ("tagging" types, to formalize their use)
    - Types wrapping raw/primitive types (e.g RawRepresentable)
- Extensibility
    - Extending types. "Attaching" functionality to data, while keeping data and functionality separated
- Asynchronous (and parallel) programming
    - Tasks
    - Callbacks
