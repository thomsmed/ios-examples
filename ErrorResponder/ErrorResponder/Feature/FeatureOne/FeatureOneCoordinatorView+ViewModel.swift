//
//  FeatureOneCoordinatorView+ViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

extension FeatureOneCoordinatorView {
    @Observable
    final class ViewModel: ErrorResponderViewModel {

        private(set) var blocked: Bool = false

        private(set) var pageOneViewModel: PageOneFeatureOneView.ViewModel

        var showAlert: Bool = false
        private(set) var alertDetails: AlertDetails? {
            didSet { showAlert = alertDetails != nil }
        }

        init() {
            pageOneViewModel = PageOneFeatureOneView.ViewModel()

            super.init()

            pageOneViewModel.parent = self
        }

        override func respond(to error: any Error) async -> ErrorEvaluation {
            switch error {
                case let featureOneError as FeatureOneError:
                    switch featureOneError {
                        case .blocked:
                            return await withCheckedContinuation { continuation in
                                alertDetails = AlertDetails(
                                    title: "You are blocked",
                                    message: "You have been blocked from Feature One until you re-launch Feature One.",
                                    actions: [
                                        AlertDetails.Action(title: "Ok") { [weak self] in
                                            continuation.resume(returning: .cancel)
                                            self?.blocked = true
                                        },
                                    ]
                                )
                            }

                        case .common(let error):
                            return await parent?.respond(to: error) ?? .abort
                    }

                default:
                    return await parent?.respond(to: error) ?? .abort
            }
        }
    }
}

// MARK: View Events

extension FeatureOneCoordinatorView.ViewModel {
    func onDisappear() {
        blocked = false
    }
}
