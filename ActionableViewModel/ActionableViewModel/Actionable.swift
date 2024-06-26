//
//  Actionable.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import Foundation

/// A simple protocol representing types that emit actions.
/// Typically ViewModels that emit actions after user interaction (e.g button tap),
/// a some completed async work (e.g network request) or as a result of a completed (or partially completed) user flow/journey.
@MainActor protocol Actionable<Action>: Sendable {
    associatedtype Action: Sendable
    var onAction: ((Action) -> Void)? { get set }
}

open class ActionableViewModel<Action: Sendable>: Actionable, ObservableObject {
    var onAction: ((Action) -> Void)?

    init(onAction: ((Action) -> Void)?) {
        self.onAction = onAction
    }
}
