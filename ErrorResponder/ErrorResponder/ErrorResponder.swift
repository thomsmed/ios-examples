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
    var parent: (any ErrorResponder)? { get set }

    @discardableResult
    func respond(to error: any Error) async -> ErrorEvaluation
}

@MainActor public struct RespondToErrorAction {
    let respondToError: (any Error) async -> ErrorEvaluation

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
    func respondToError(_ respondToError: @escaping (any Error) async -> ErrorEvaluation) -> some View {
        environment(\.respondToError, RespondToErrorAction(respondToError: respondToError))
    }
}
