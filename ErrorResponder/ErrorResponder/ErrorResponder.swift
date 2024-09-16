//
//  ErrorResponder.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

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

public protocol ErrorResponder: AnyObject {
    var parent: (any ErrorResponder)? { get set }

    func respond(to error: any Error) async -> ErrorEvaluation
}
