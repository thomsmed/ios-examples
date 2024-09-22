//
//  FeatureTwoCoordinatorView+ViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

extension FeatureTwoCoordinatorView {
    @Observable
    final class ViewModel: ErrorResponderViewModel {

        private(set) var blocked: Bool = false

        private(set) var pageOneViewModel: PageOneFeatureTwoView.ViewModel

        var showAlert: Bool = false
        private(set) var alertDetails: AlertDetails? {
            didSet { showAlert = alertDetails != nil }
        }

        init() {
            pageOneViewModel = PageOneFeatureTwoView.ViewModel()

            super.init()

            pageOneViewModel.parentResponder = self
        }

        override func respond(to error: any Error) async -> ErrorEvaluation {
            switch error {
                case let featureTwoError as FeatureTwoError:
                    switch featureTwoError {
                        case .blocked:
                            return await withCheckedContinuation { continuation in
                                alertDetails = AlertDetails(
                                    title: "You are blocked",
                                    message: "You have been blocked from Feature Two until you re-launch Feature Two.",
                                    actions: [
                                        AlertDetails.Action(title: "Ok") { [weak self] in
                                            continuation.resume(returning: .cancel)
                                            self?.blocked = true
                                        },
                                    ]
                                )
                            }

                        case .common(let error):
                            return await parentResponder?.respond(to: error) ?? .abort
                    }

                default:
                    return await parentResponder?.respond(to: error) ?? .abort
            }
        }
    }
}

// MARK: View Events

extension FeatureTwoCoordinatorView.ViewModel {
    func onDisappear() {
        blocked = false
    }
}
