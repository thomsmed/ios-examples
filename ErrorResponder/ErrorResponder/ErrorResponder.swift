//
//  ErrorResponder.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

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
    let respondToError: @Sendable (any Error) async -> ErrorEvaluation

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
    func respondToError(_ respondToError: @escaping @Sendable (any Error) async -> ErrorEvaluation) -> some View {
        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
    }
}

// MARK: Alternative with boolean for retry or not

@MainActor public protocol RetryEvaluator: AnyObject {
    var parentEvaluator: (any RetryEvaluator)? { get set }

    @discardableResult
    func shouldRetry(_ error: any Error) async -> Bool
}

@MainActor public struct ShouldRetryErrorAction {
    let shouldRetryError: @Sendable (any Error) async -> Bool

    @discardableResult
    func callAsFunction(_ error: any Error) async -> Bool {
        return await shouldRetryError(error)
    }
}

public struct ShouldRetryErrorActionEnvironmentKey: EnvironmentKey {
    public static let defaultValue: ShouldRetryErrorAction = ShouldRetryErrorAction { _ in
        assertionFailure("Unhandled error")
        return false
    }
}

public extension EnvironmentValues {
    var shouldRetryError: ShouldRetryErrorAction {
        get { self[ShouldRetryErrorActionEnvironmentKey.self] }
        set { self[ShouldRetryErrorActionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func shouldRetryError(_ shouldRetryError: @escaping @Sendable (any Error) async -> Bool) -> some View {
        environment(\.shouldRetryError, ShouldRetryErrorAction(shouldRetryError: shouldRetryError))
    }
}

// MARK: Alternative with escaping retry closure

@MainActor public protocol ErrorHandler: AnyObject {
    var errorHandler: (any ErrorHandler)? { get set }

    func handle(_ error: any Error, _ retry: @escaping () -> Void)
}

@MainActor public struct HandleErrorAction {
    let handleError: @Sendable (any Error, _ retry: @escaping @Sendable () -> Void) -> Void

    func callAsFunction(_ error: any Error, _ retry: @escaping @Sendable () -> Void) -> Void {
        handleError(error, retry)
    }
}

public struct HandleErrorActionEnvironmentKey: EnvironmentKey {
    public static let defaultValue: HandleErrorAction = HandleErrorAction { _, _ in
        assertionFailure("Unhandled error")
    }
}

public extension EnvironmentValues {
    var handleError: HandleErrorAction {
        get { self[HandleErrorActionEnvironmentKey.self] }
        set { self[HandleErrorActionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func handleError(_ handleError: @escaping @Sendable (any Error, @escaping @Sendable () -> Void) -> Void) -> some View {
        environment(\.handleError, HandleErrorAction(handleError: handleError))
    }
}
