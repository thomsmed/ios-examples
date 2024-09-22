//
//  ErrorResponderViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

public class ErrorResponderViewModel: ErrorResponder {
    public weak var parentResponder: (any ErrorResponder)? = nil

    public init(parentResponder: (any ErrorResponder)? = nil) {
        self.parentResponder = parentResponder
    }

    public func respond(to error: any Error) async -> ErrorEvaluation {
        guard let parentResponder else {
            assertionFailure("Unhandled error in ErrorResponder chain")
            return .abort
        }

        return await parentResponder.respond(to: error)
    }
}
