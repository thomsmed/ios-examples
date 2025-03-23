//
//  SignalingKeychain.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// An abstraction around the `Keychain` signals whenever a given value change.
/// The benefit of `SignalingKeychain` over `ObservableKeychain` is that `SignalingKeychain` only signal changes on a per value basis.
final class SignalingKeychain: Sendable {
    protocol Storage: Sendable {
        func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws
        func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value?
        func delete(for key: String, under namespace: String) throws
        func deleteAll(under namespace: String) throws
        func keys(under namespace: String) throws -> [String]
    }

    final class Signal: ObservableObject, Sendable {
        private let notificationCenter: NotificationCenter

        nonisolated(unsafe) private var observer: (any NSObjectProtocol)?

        internal init(
            for key: String,
            under namespace: String,
            observing signalingKeychain: SignalingKeychain,
            using notificationCenter: NotificationCenter
        ) {
            self.notificationCenter = notificationCenter

            self.observer = notificationCenter.addObserver(
                forName: SignalingKeychain.didChangeNotification,
                object: signalingKeychain,
                queue: .main
            ) { [weak self] notification in
                guard
                    let userInfo = notification.userInfo as? [String: String],
                    userInfo[SignalingKeychain.userInfoNamespaceKey] == namespace
                else {
                    return
                }

                let changedKey = userInfo[SignalingKeychain.userInfoKeyKey]

                if changedKey == nil || changedKey == key {
                    self?.objectWillChange.send()
                }
            }
        }

        deinit {
            if let observer {
                notificationCenter.removeObserver(observer)
            }
        }
    }

    private static let didChangeNotification = Notification.Name("\(String(describing: SignalingKeychain.self)).didChangeNotification")
    private static let userInfoKeyKey = "key"
    private static let userInfoNamespaceKey = "namespace"

    static let shared = SignalingKeychain(
        storage: KeychainStorage(),
        notificationCenter: .default
    )

    private let storage: any Storage
    private let notificationCenter: NotificationCenter

    init(storage: any Storage, notificationCenter: NotificationCenter) {
        self.storage = storage
        self.notificationCenter = notificationCenter
    }

    func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws {
        try storage.set(value, for: key, under: namespace)

        let notification = Notification(
            name: Self.didChangeNotification,
            object: self,
            userInfo: [
                Self.userInfoKeyKey: key,
                Self.userInfoNamespaceKey: namespace
            ]
        )

        notificationCenter.post(notification)
    }

    func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value? {
        try storage.value(for: key, under: namespace)
    }

    func delete(for key: String, under namespace: String) throws {
        try storage.delete(for: key, under: namespace)

        let notification = Notification(
            name: Self.didChangeNotification,
            object: self,
            userInfo: [
                Self.userInfoKeyKey: key,
                Self.userInfoNamespaceKey: namespace
            ]
        )

        notificationCenter.post(notification)
    }

    func deleteAll(under namespace: String) throws {
        try storage.deleteAll(under: namespace)

        let notification = Notification(
            name: Self.didChangeNotification,
            object: self,
            userInfo: [
                Self.userInfoNamespaceKey: namespace
            ]
        )

        notificationCenter.post(notification)
    }

    func keys(under namespace: String) throws -> [String] {
        try storage.keys(under: namespace)
    }

    func signal(for key: String, under namespace: String) -> Signal {
        Signal(for: key, under: namespace, observing: self, using: notificationCenter)
    }
}

// MARK: KeychainStorage+SignalingKeychain.Storage

extension KeychainStorage: SignalingKeychain.Storage {}

// MARK: SignalingKeychained

import SwiftUI

@propertyWrapper struct SignalingKeychained<Value: Codable>: DynamicProperty {
    private let key: String
    private let namespace: String
    private let keychain: SignalingKeychain

    @StateObject private var signal: SignalingKeychain.Signal

    init(
        key: String,
        namespace: String,
        keychain: SignalingKeychain = .shared
    ) {
        self.key = key
        self.namespace = namespace
        self.keychain = keychain

        self._signal = StateObject(wrappedValue: keychain.signal(for: key, under: namespace))
    }

    var wrappedValue: Value? {
        get {
            try? keychain.value(for: key, under: namespace)
        }
        nonmutating set {
            if let newValue {
                try? keychain.set(newValue, for: key, under: namespace)
            } else {
                try? keychain.delete(for: key, under: namespace)
            }
        }
    }

    var projectedValue: Binding<Value?> {
        Binding(get: { [keychain, key, namespace] in
            try? keychain.value(for: key, under: namespace)
        }, set: { [keychain, key, namespace] newValue in
            if let newValue {
                try? keychain.set(newValue, for: key, under: namespace)
            } else {
                try? keychain.delete(for: key, under: namespace)
            }
        })
    }
}
