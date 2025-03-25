//
//  SignalingDefaults.swift
//  SignalingStorage
//
//  Created by Thomas Smedmann on 23/03/2025.
//

import Foundation

/// An abstraction around `UserDefaults` that signals whenever a given value change.
/// The benefit of `SignalingDefaults` over `ObservableDefaults` is that `SignalingDefaults` only signal changes on a per value basis.
final class SignalingDefaults: Sendable {
    protocol Storage: Sendable {
        func set<Value: Encodable>(_ value: Value, for key: String, under namespace: String) throws
        func value<Value: Decodable>(for key: String, under namespace: String) throws -> Value?
        func delete(for key: String, under namespace: String) throws
    }

    final class Signal: ObservableObject, Sendable {
        private let notificationCenter: NotificationCenter

        nonisolated(unsafe) private var observer: (any NSObjectProtocol)?

        init(
            for key: String,
            under namespace: String,
            observing signalingDefaults: SignalingDefaults,
            using notificationCenter: NotificationCenter
        ) {
            self.notificationCenter = notificationCenter

            self.observer = notificationCenter.addObserver(
                forName: SignalingDefaults.didChangeNotification,
                object: signalingDefaults,
                queue: .main
            ) { [weak self] notification in
                guard
                    let userInfo = notification.userInfo as? [String: String],
                    userInfo[SignalingDefaults.userInfoNamespaceKey] == namespace
                else {
                    return
                }

                let changedKey = userInfo[SignalingDefaults.userInfoKeyKey]

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

    @MainActor final class SynchronizedValue<Value: Codable>: ObservableObject, Sendable {
        private let key: String
        private let namespace: String
        private let signalingDefaults: SignalingDefaults
        private let notificationCenter: NotificationCenter

        nonisolated(unsafe) private var observer: (any NSObjectProtocol)?

        private var _value: Value?

        init(
            for key: String,
            under namespace: String,
            observing signalingDefaults: SignalingDefaults,
            using notificationCenter: NotificationCenter
        ) {
            self.notificationCenter = notificationCenter
            self.signalingDefaults = signalingDefaults
            self.namespace = namespace
            self.key = key

            self.observer = notificationCenter.addObserver(
                forName: SignalingDefaults.didChangeNotification,
                object: signalingDefaults,
                queue: .main
            ) { [weak self] notification in
                guard
                    let self,
                    let userInfo = notification.userInfo as? [String: String],
                    userInfo[SignalingDefaults.userInfoNamespaceKey] == namespace
                else {
                    return
                }

                let changedKey = userInfo[SignalingDefaults.userInfoKeyKey]

                if changedKey == nil || changedKey == key {
                    let newValue: Value? = try? self.signalingDefaults.value(for: key, under: namespace)

                    MainActor.assumeIsolated {
                        self._value = newValue
                        self.objectWillChange.send()
                    }
                }
            }

            self._value = try? signalingDefaults.value(for: key, under: namespace)
        }

        var value: Value? {
            get {
                _value
            }
            set {
                _value = newValue

                if let newValue {
                    try? signalingDefaults.set(newValue, for: key, under: namespace)
                } else {
                    try? signalingDefaults.delete(for: key, under: namespace)
                }
            }
        }

        deinit {
            if let observer {
                notificationCenter.removeObserver(observer)
            }
        }
    }

    private static let didChangeNotification = Notification.Name("\(String(describing: SignalingDefaults.self)).didChangeNotification")
    private static let userInfoKeyKey = "key"
    private static let userInfoNamespaceKey = "namespace"

    static let shared = SignalingDefaults(
        storage: DefaultsStorage(),
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
    }

    func signal(for key: String, under namespace: String) -> Signal {
        Signal(for: key, under: namespace, observing: self, using: notificationCenter)
    }

    @MainActor func synchronizedValue<Value: Codable>(for key: String, under namespace: String) -> SynchronizedValue<Value> {
        SynchronizedValue(for: key, under: namespace, observing: self, using: notificationCenter)
    }
}

// MARK: DefaultsStorage+SignalingDefaults.Storage

extension DefaultsStorage: SignalingDefaults.Storage {}

// MARK: SignalingDefaulted

import SwiftUI

@propertyWrapper struct SignalingDefaulted<Value: Codable>: DynamicProperty {
    private let key: String
    private let namespace: String
    private let defaults: SignalingDefaults

    @StateObject private var signal: SignalingDefaults.Signal

    init(
        key: String,
        namespace: String,
        defaults: SignalingDefaults = .shared
    ) {
        self.key = key
        self.namespace = namespace
        self.defaults = defaults

        self._signal = StateObject(wrappedValue: defaults.signal(for: key, under: namespace))
    }

    var wrappedValue: Value? {
        get {
            try? defaults.value(for: key, under: namespace)
        }
        nonmutating set {
            if let newValue {
                try? defaults.set(newValue, for: key, under: namespace)
            } else {
                try? defaults.delete(for: key, under: namespace)
            }
        }
    }

    var projectedValue: Binding<Value?> {
        Binding(get: { [defaults, key, namespace] in
            try? defaults.value(for: key, under: namespace)
        }, set: { [defaults, key, namespace] newValue in
            if let newValue {
                try? defaults.set(newValue, for: key, under: namespace)
            } else {
                try? defaults.delete(for: key, under: namespace)
            }
        })
    }
}

// MARK: SynchronizedDefaulted

import SwiftUI

@MainActor @propertyWrapper struct SynchronizedDefaulted<Value: Codable>: DynamicProperty {
    @StateObject private var synchronizedValue: SignalingDefaults.SynchronizedValue<Value>

    init(
        key: String,
        namespace: String,
        defaults: SignalingDefaults = .shared
    ) {
        self._synchronizedValue = StateObject(
            wrappedValue: defaults.synchronizedValue(for: key, under: namespace)
        )
    }

    var wrappedValue: Value? {
        get {
            synchronizedValue.value
        }
        nonmutating set {
            synchronizedValue.value = newValue
        }
    }

    var projectedValue: Binding<Value?> {
        $synchronizedValue.value
    }
}
