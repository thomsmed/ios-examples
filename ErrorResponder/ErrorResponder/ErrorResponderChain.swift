//
//  ErrorResponderChain.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 07/10/2024.
//

import Foundation

/// Convenience type that by it self represent an Error Responder Chain.
/// Could be used standalone to combine the error handling in any arbitrary components,
/// but could also act as a bridge between the View layer (SwiftUI / UIKit with ViewModels) and any other part of the app.
/// E.g services or anything that just want to connect to the Error Responder chain (permanently or temporarily).
///
/// Error Responders are added to the front of the chain, hence the last responder to register is the first to (potentially) handle new Errors.
@MainActor public final class ErrorResponderChain: ErrorResponder {
    private var errorResponders: [(uuid: UUID, respondTo: (any Error) async -> ErrorEvaluation?)] = []

    public var parentResponder: (any ErrorResponder)? = nil

    init(parentResponder: (any ErrorResponder)? = nil) {
        self.parentResponder = parentResponder
    }

    public func connect(_ respondTo: @escaping (any Error) async -> ErrorEvaluation?) -> UUID {
        let uuid = UUID()
        errorResponders.insert((uuid: uuid, respondTo: respondTo), at: 0)
        return uuid
    }

    public func disconnect(_ uuid: UUID) {
        errorResponders.removeAll(where: { $0.uuid == uuid })
    }

    public func respond(to error: any Error) async -> ErrorEvaluation {
        for errorResponder in errorResponders {
            if let evaluation = await errorResponder.respondTo(error) {
                return evaluation
            }
        }

        guard let parentResponder else {
            assertionFailure("Unhandled error")
            return .proceed
        }

        return await parentResponder.respond(to: error)
    }
}
