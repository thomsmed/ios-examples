//
//  PageOneFeatureOneView+ViewModel.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

extension PageOneFeatureOneView {
    @Observable
    final class ViewModel: ErrorResponderViewModel {

        var showAlert: Bool = false
        private(set) var alertDetails: AlertDetails? {
            didSet { showAlert = alertDetails != nil }
        }

        override func respond(to error: any Error) async -> ErrorEvaluation {
            switch error {
            case let pageOneFeatureOneError as PageOneFeatureOneError:
                switch pageOneFeatureOneError {
                case .wrongInput:
                    return await withCheckedContinuation { continuation in
                        alertDetails = AlertDetails(
                            title: "Wrong input",
                            message: "Please try again. With the right input, please...",
                            actions: [
                                AlertDetails.Action(title: "Ok") {
                                    continuation.resume(returning: .cancel)
                                },
                            ]
                        )
                    }

                case .needsConfirmation:
                    return await withCheckedContinuation { continuation in
                        alertDetails = AlertDetails(
                            title: "Are you sure about this?",
                            message: "You need to be 100% sure before you continue.",
                            actions: [
                                AlertDetails.Action(title: "No...") {
                                    continuation.resume(returning: .cancel)
                                },
                                AlertDetails.Action(title: "Yes") {
                                    continuation.resume(returning: .proceed)
                                },
                            ]
                        )
                    }

                case .feature(let error):
                    return await parentResponder?.respond(to: error) ?? .abort

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

extension PageOneFeatureOneView.ViewModel {
    func didTapTriggerPageLocalError() {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: .milliseconds(100)) // Simulate networking

                throw PageOneFeatureOneError.needsConfirmation
            } catch {
                switch await self.respond(to: error) {
                case .proceed:
                    break
                case .cancel:
                    break
                case .retry:
                    self.didTapTriggerPageLocalError()
                case .abort:
                    break
                }
            }
        }
    }

    func didTapTriggerFeatureError() {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: .milliseconds(100)) // Simulate networking

                throw PageOneFeatureOneError.feature(.blocked)
            } catch {
                switch await self.respond(to: error) {
                case .proceed:
                    break
                case .cancel:
                    break
                case .retry:
                    self.didTapTriggerFeatureError()
                case .abort:
                    break
                }
            }
        }
    }

    func didTapTriggerCommonError() {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: .milliseconds(100)) // Simulate networking

                throw PageOneFeatureOneError.common(.blocked)
            } catch {
                switch await self.respond(to: error) {
                case .proceed:
                    break
                case .cancel:
                    break
                case .retry:
                    self.didTapTriggerCommonError()
                case .abort:
                    break
                }
            }
        }
    }
}
