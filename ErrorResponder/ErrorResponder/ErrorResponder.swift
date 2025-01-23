//
//  ErrorResponder.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation
import SwiftUI

public enum ErrorEvaluation: Sendable {
    /// The `Error` has been handled by all necessary or available means.
    /// Proceed in whatever way that is natural.
    case proceed

    /// The `Error` has been handled by all necessary or available means.
    /// Retry whatever action caused the `Error` to occur.
    case retry

    /// The `Error` has been handled by all necessary or available means.
    /// Cancel any succeeding actions, and stay put.
    case cancel

    /// The `Error` has been handled by all necessary or available means.
    /// Abort whatever flow/process the `Error` occurred in, as the `Error` was too severe.
    case abort
}

@MainActor public protocol ErrorResponder: Sendable, AnyObject {
    var parentResponder: (any ErrorResponder)? { get set }

    @discardableResult
    func respond(to error: any Error) async -> ErrorEvaluation
}

@MainActor public struct RespondToErrorAction {
    let respondToError: @MainActor (any Error) async -> ErrorEvaluation

    @discardableResult
    func callAsFunction(_ error: any Error) async -> ErrorEvaluation {
        return await respondToError(error)
    }
}

public struct RespondToErrorActionEnvironmentKey: EnvironmentKey {
    public static let defaultValue: RespondToErrorAction = RespondToErrorAction { error in
        assertionFailure("Unhandled error: \(error)")
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
    func respondToError(_ respondToError: @MainActor @escaping (any Error) async -> ErrorEvaluation) -> some View {
        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
    }
}

// MARK: Alternative 1: With escaping retry closure

//@MainActor public protocol ErrorResponder: AnyObject {
//    var parentResponder: (any ErrorResponder)? { get set }
//
//    func respond(to error: any Error, _ completion: @MainActor @escaping (ErrorEvaluation) -> Void)
//}
//
//@MainActor public struct RespondToErrorAction {
//    let respondToError: @MainActor (any Error, _ completion: @MainActor @escaping (ErrorEvaluation) -> Void) -> Void
//
//    func callAsFunction(_ error: any Error, _ completion: @MainActor @escaping (ErrorEvaluation) -> Void) -> Void {
//        respondToError(error, completion)
//    }
//}
//
//public struct RespondToErrorActionEnvironmentKey: EnvironmentKey {
//    public static let defaultValue: RespondToErrorAction = RespondToErrorAction { _, completion in
//        assertionFailure("Unhandled error")
//        completion(.proceed)
//    }
//}
//
//public extension EnvironmentValues {
//    var respondToError: RespondToErrorAction {
//        get { self[RespondToErrorActionEnvironmentKey.self] }
//        set { self[RespondToErrorActionEnvironmentKey.self] = newValue }
//    }
//}
//
//public extension View {
//    func respondToError(_ respondToError: @MainActor @escaping (any Error, @MainActor @escaping (ErrorEvaluation) -> Void) -> Void) -> some View {
//        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
//    }
//}

// MARK: Alternative 2: With boolean for retry or not

//@MainActor public protocol ErrorResponder: AnyObject {
//    var parentResponder: (any ErrorResponder)? { get set }
//
//    @discardableResult
//    func shouldRetry(after error: any Error) async -> Bool
//}
//
//@MainActor public struct RespondToErrorAction {
//    let shouldRetryAfterError: @MainActor (any Error) async -> Bool
//
//    @discardableResult
//    func callAsFunction(_ error: any Error) async -> Bool {
//        return await shouldRetryAfterError(error)
//    }
//}
//
//public struct RespondToErrorActionEnvironmentKey: EnvironmentKey {
//    public static let defaultValue: RespondToErrorAction = RespondToErrorAction { _ in
//        assertionFailure("Unhandled error")
//        return false
//    }
//}
//
//public extension EnvironmentValues {
//    var shouldRetryAfterError: RespondToErrorAction {
//        get { self[RespondToErrorActionEnvironmentKey.self] }
//        set { self[RespondToErrorActionEnvironmentKey.self] = newValue }
//    }
//}
//
//public extension View {
//    func shouldRetryAfterError(_ shouldRetryAfterError: @MainActor @escaping (any Error) async -> Bool) -> some View {
//        environment(\.shouldRetryAfterError, RespondToErrorAction(shouldRetryAfterError: shouldRetryAfterError))
//    }
//}

// MARK: Alternative 3: With escaping retry closure

//@MainActor public protocol ErrorResponder: AnyObject {
//    var parentResponder: (any ErrorResponder)? { get set }
//
//    func respond(to error: any Error, _ retry: @MainActor @escaping () -> Void)
//}
//
//@MainActor public struct RespondToErrorAction {
//    let respondToError: @MainActor (any Error, _ retry: @MainActor @escaping () -> Void) -> Void
//
//    func callAsFunction(_ error: any Error, _ retry: @MainActor @escaping () -> Void) -> Void {
//        respondToError(error, retry)
//    }
//}
//
//public struct RespondToErrorActionEnvironmentKey: EnvironmentKey {
//    public static let defaultValue: RespondToErrorAction = RespondToErrorAction { _, _ in
//        assertionFailure("Unhandled error")
//    }
//}
//
//public extension EnvironmentValues {
//    var respondToError: RespondToErrorAction {
//        get { self[RespondToErrorActionEnvironmentKey.self] }
//        set { self[RespondToErrorActionEnvironmentKey.self] = newValue }
//    }
//}
//
//public extension View {
//    func respondToError(_ respondToError: @MainActor @escaping (any Error, @MainActor @escaping () -> Void) -> Void) -> some View {
//        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
//    }
//}
