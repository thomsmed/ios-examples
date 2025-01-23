//
//  RootCoordinatorView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

// MARK: UserAgreementProblem

struct UserAgreementProblemExtras: HTTPAPIProblemExtras {
    static let associatedProblemType: String? = "https://some.domain/problem/user-agreement"

    let agreementURL: URL
}
typealias UserAgreementProblem = HTTPAPIProblem<UserAgreementProblemExtras>

extension UserAgreementProblem {
    // One would typically not instantiate a Problem explicitly,
    // but rather via decoding of JSON returned from the back-end.
    static let `default` = try! UserAgreementProblem(
        title: "Problem!",
        status: 400,
        detail: "Feature three feature-wide problem",
        instance: "https://some.domain/some/poroblem/instance",
        extras: UserAgreementProblemExtras(agreementURL: URL(string: "https://example.ios")!)
    )
}

// MARK: RootCoordinatorView

struct RootCoordinatorView: View {
    @Environment(\.respondToError) private var respondToError
    @Environment(\.openURL) private var openURL

    @Bindable var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.blocked {
                VStack {
                    Spacer()
                    Text("Ups! You are blocked until you re-launch the app")
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.blurReplace)
            } else {
                TabView {
                    Tab("Feature One", systemImage: "1.square") {
                        FeatureOneCoordinatorView(viewModel: viewModel.featureOneCoordinatorViewModel)
                    }

                    Tab("Feature Two", systemImage: "2.square") {
                        FeatureTwoCoordinatorView(viewModel: viewModel.featureTwoCoordinatorViewModel)
                    }

                    Tab("Feature Three", systemImage: "3.square") {
                        FeatureThreeCoordinatorView()
                    }
                }
            }
        }
        .animation(.default, value: viewModel.blocked)
        .alert(presenting: viewModel.alertDetails, isPresented: $viewModel.showAlert)
        .respondToError { error in
            guard let userAgreementProblem = error as? UserAgreementProblem else {
                return await respondToError(error)
            }

            return await withCheckedContinuation { continuation in
                viewModel.alertDetails = AlertDetails(
                    title: "Please agree to the terms!",
                    message: "Feature Three will be available once you've agreed to our terms & conditions",
                    actions: [
                        AlertDetails.Action(title: "Decline") {
                            continuation.resume(returning: .abort)
                        },
                        AlertDetails.Action(title: "Read more") {
                            openURL(userAgreementProblem.extras.agreementURL) { _ in
                                continuation.resume(returning: .cancel)
                            }
                        },
                        AlertDetails.Action(title: "Agree, then try again") {
                            continuation.resume(returning: .retry)
                        }
                    ]
                )
            }
        }
    }
}
