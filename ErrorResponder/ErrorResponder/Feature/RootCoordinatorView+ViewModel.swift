//
//  RootCoordinatorView+ViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

extension RootCoordinatorView {
    @Observable
    final class ViewModel: ErrorResponderViewModel {

        private(set) var blocked: Bool = false

        private(set) var featureOneCoordinatorViewModel: FeatureOneCoordinatorView.ViewModel
        private(set) var featureTwoCoordinatorViewModel: FeatureTwoCoordinatorView.ViewModel

        var showAlert: Bool = false
        var alertDetails: AlertDetails? {
            didSet { showAlert = alertDetails != nil }
        }

        init() {
            featureOneCoordinatorViewModel = FeatureOneCoordinatorView.ViewModel()
            featureTwoCoordinatorViewModel = FeatureTwoCoordinatorView.ViewModel()

            super.init()

            featureOneCoordinatorViewModel.parentResponder = self
            featureTwoCoordinatorViewModel.parentResponder = self
        }

        override func respond(to error: any Error) async -> ErrorEvaluation {
            switch error {
            case let commonError as CommonError:
                switch commonError {
                case .networkTrouble:
                    return await withCheckedContinuation { continuation in
                        alertDetails = AlertDetails(
                            title: "Network Issue",
                            message: "Check your network connection",
                            actions: [
                                AlertDetails.Action(title: "Cancel") {
                                    continuation.resume(returning: .cancel)
                                },
                                AlertDetails.Action(title: "Retry") {
                                    continuation.resume(returning: .retry)
                                }
                            ]
                        )
                    }

                case .sessionExpired:
                    try? await Task.sleep(for: .seconds(1)) // Simulate session refresh
                    return .retry

                case .blocked:
                    return await withCheckedContinuation { continuation in
                        alertDetails = AlertDetails(
                            title: "You are blocked",
                            message: "You have been blocked from the app until you re-launch the app.",
                            actions: [
                                AlertDetails.Action(title: "Ok") { [weak self] in
                                    continuation.resume(returning: .cancel)
                                    self?.blocked = true
                                },
                            ]
                        )
                    }
                }

            default:
                return await withCheckedContinuation { continuation in
                    alertDetails = AlertDetails(
                        title: "Ups!",
                        message: "Something unexpected happened...",
                        actions: [
                            AlertDetails.Action(title: "Ok") {
                                continuation.resume(returning: .abort)
                            }
                        ]
                    )
                }
            }
        }
    }
}
