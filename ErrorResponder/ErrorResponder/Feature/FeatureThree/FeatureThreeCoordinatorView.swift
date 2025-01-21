//
//  FeatureThreeCoordinatorView.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

//
// The concept of a `HTTPAPIProblem` is stolen from [Handling HTTP API Errors with Problem Details](https://medium.com/@thomsmed/handling-http-api-errors-with-problem-details-398a9967aee4).
//

import SwiftUI

// MARK: FeatureThreeFeatureWideProblem

struct FeatureThreeFeatureWideProblemExtras: HTTPAPIProblemExtras {
    static let associatedProblemType: String? = "urn:some:feature:three:feature-wide:problem"
}
typealias FeatureThreeFeatureWideProblem = HTTPAPIProblem<FeatureThreeFeatureWideProblemExtras>

extension FeatureThreeFeatureWideProblem {
    // One would typically not instantiate a Problem explicitly,
    // but rather via decoding of JSON returned from the back-end.
    static let `default` = try! FeatureThreeFeatureWideProblem(
        title: "Problem!",
        status: 400,
        detail: "Feature three feature-wide problem",
        instance: "https://some.domain/some/poroblem/instance",
        extras: FeatureThreeFeatureWideProblemExtras()
    )
}

// MARK: FeatureThreeCoordinatorView

struct FeatureThreeCoordinatorView: View {
    @Environment(\.respondToError) private var respondToError

    @State private var blocked: Bool = false

    @State private var isPresentingAlert: Bool = false
    @State private var alertDetails: AlertDetails? = nil {
        didSet {
            isPresentingAlert = alertDetails != nil
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if blocked {
                    VStack {
                        Spacer()
                        Text("Ups! You are blocked until you re-launch Feature Three")
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.blurReplace)
                } else {
                    PageOneFeatureThreeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.default, value: blocked)
        }
        .alert(presenting: alertDetails, isPresented: $isPresentingAlert)
        .respondToError { error in
            if error is FeatureThreeFeatureWideProblem {
                blocked = true
                return .cancel
            } else {
                return await respondToError(error)
            }
        }
        .onDisappear {
            blocked = false
        }
    }
}
