//
//  ErrorResponderViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

public class ErrorResponderViewModel: ErrorResponder {
    public weak var parent: (any ErrorResponder)? = nil

    public init(parent: (any ErrorResponder)? = nil) {
        self.parent = parent
    }

    public func respond(to error: any Error) async -> ErrorEvaluation {
        guard let parent = parent else {
            assertionFailure("Unhandled error in ErrorResponder chain")
            return .abort
        }

        return await parent.respond(to: error)
    }
}
