//
//  PageOneFeatureThreeView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

//
// The concept of a `HTTPAPIProblem` is stolen from [Handling HTTP API Errors with Problem Details](https://medium.com/@thomsmed/handling-http-api-errors-with-problem-details-398a9967aee4).
//

import SwiftUI

// MARK: FeatureThreePageOneProblem

struct FeatureThreePageOneProblemExtras: HTTPAPIProblemExtras {
    static let associatedProblemType: String? = "urn:some:feature:three:feature-wide:problem"
}
typealias FeatureThreePageOneProblem = HTTPAPIProblem<FeatureThreePageOneProblemExtras>

extension FeatureThreePageOneProblem {
    // One would typically not instantiate a Problem explicitly,
    // but rather via decoding of JSON returned from the back-end.
    static let `default` = try! FeatureThreePageOneProblem(
        title: "Problem!",
        status: 400,
        detail: "Feature three page one problem",
        instance: "https://some.domain/some/poroblem/instance",
        extras: FeatureThreePageOneProblemExtras()
    )
}

// MARK: PageOneFeatureThreeView

struct PageOneFeatureThreeView: View {
    @Environment(\.respondToError) private var respondToError

    @State private var isPresentingAlert: Bool = false
    @State private var alertDetails: AlertDetails? = nil {
        didSet {
            isPresentingAlert = alertDetails != nil
        }
    }

    var body: some View {
        VStack {
            Button("Trigger Random Problem", action: onButtonTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .alert(presenting: alertDetails, isPresented: $isPresentingAlert)
    }

    private func onButtonTap() {
        Task {
            do {
                try await Task.sleep(for: .milliseconds(100)) // Simulate networking

                switch Int.random(in: 0..<3) {
                case 0:
                    throw FeatureThreePageOneProblem.default
                case 1:
                    throw FeatureThreeFeatureWideProblem.default
                default:
                    throw UserAgreementProblem.default
                }
            } catch is FeatureThreePageOneProblem {
                alertDetails = AlertDetails(
                    title: "Ups!",
                    message: "Looks like something went wrong...",
                    actions: [
                        AlertDetails.Action(title: "Cancel") {},
                        AlertDetails.Action(title: "Try again", handler: onButtonTap)
                    ]
                )
            } catch {
                switch await respondToError(error) {
                case .proceed:
                    break
                case .retry:
                    onButtonTap()
                case .cancel:
                    break
                case .abort:
                    break
                }
            }
        }
    }
}
