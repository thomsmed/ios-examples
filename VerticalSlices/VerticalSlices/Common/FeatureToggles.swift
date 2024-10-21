//
//  FeatureToggles.swift
//  VerticalSlices
//
//  Created by Thomas Smedmann on 15/11/2024.
//

import Foundation
import OSLog

// MARK: Logger extensions

public extension Logger {
    static let featureToggles = Logger(
        subsystem: "ios.example.VerticalSlices",
        category: "FeatureToggles"
    )
}

// MARK: Feature

public enum Feature {
    case featureOne
    case featureTwo
    case featureThree
    case secretFeature
}

// MARK: FeatureToggleSyncEngine

public protocol FeatureToggleSyncEngine: Sendable {
    func onSync(_ completion: @escaping () -> Void)
    func hasEnabled(_ feature: Feature) -> Bool
}

// MARK: TestFeatureToggleSyncEngine

public final class TestFeatureToggleSyncEngine: @unchecked Sendable, FeatureToggleSyncEngine {

    var features: [Feature: Bool] = [:]

    public func onSync(_ completion: @escaping () -> Void) {
        Logger.networking.warning("You are using \(String(describing: Self.self))")
        completion()
    }

    public func hasEnabled(_ feature: Feature) -> Bool {
        Logger.networking.warning("You are using \(String(describing: Self.self))")
        return features[feature] ?? false
    }
}

// MARK: RemoteFeatureToggleSyncEngine

public final class RemoteFeatureToggleSyncEngine: @unchecked Sendable, FeatureToggleSyncEngine {
    public func onSync(_ completion: @escaping () -> Void) {
        // ...
        completion()
    }

    public func hasEnabled(_ feature: Feature) -> Bool {
        // ...
        return false
    }
}

// MARK: FeatureToggles

public final class FeatureToggles: Sendable, ObservableObject {
    private let syncEngine: FeatureToggleSyncEngine

    init(syncEngine: FeatureToggleSyncEngine) {
        self.syncEngine = syncEngine
    }

    func hasEnabled(_ feature: Feature) -> Bool {
        syncEngine.hasEnabled(feature)
    }
}

// MARK: Exposing FeatureToggles to SwiftUI

import SwiftUI

@MainActor @propertyWrapper public struct FeatureToggle: DynamicProperty {
    @EnvironmentObject private var featureToggles: FeatureToggles

    private let feature: Feature

    public init(_ feature: Feature) {
        self.feature = feature
    }

    public var wrappedValue: Bool {
        featureToggles.hasEnabled(feature)
    }
}

public extension View {
    func featureToggles(_ featureToggles: FeatureToggles) -> some View {
        environmentObject(featureToggles)
    }
}
