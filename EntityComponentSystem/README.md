# Entity Component System

The [Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) architecture pattern is mostly known in the world of game development.
But the general ideas could be applied to all kind of software.

Sources of inspiration:

- Point-Free's [Tagged](https://github.com/pointfreeco/swift-tagged).
- Sindre Sørhus's [Defaults](https://github.com/sindresorhus/Defaults).
- Dmitriy Zharov's [SwiftSecurity](https://github.com/dm-zharov/swift-security).

## Entities

Your domain models (with their associated domain logic).

If a domain model should interact with one or more systems,
add components to it in the form of extension methods.

## Systems (and their components)

- HTTP with `HTTPSession` (a thin wrapper around `URLSession`).
    - `Endpoint<Resource>`.
- Key-value store with `Defaults` (a thin wrapper around `UserDefaults`).
    - `DefaultsEntry<Target>` (and the `DefaultsStored` protocol).
- Secure key-value store with `SecureDefaults` (a thin wrapper around `Keychain services`).
    - `SecureDefaultsEntry<Target>` (and the `SecureDefaultsStored` protocol).
- Managed cryptographic keys with `KeyVault` (a thin wrapper around `Keychain services`).
    - `KeyVaultEntry<Key>` (and the `KeyVaultManaged` protocol).
