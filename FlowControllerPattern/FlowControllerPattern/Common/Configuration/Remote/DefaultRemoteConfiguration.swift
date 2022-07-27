//
//  DefaultRemoteConfiguration.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation
import Combine

final class DefaultRemoteConfiguration {

    private struct FeatureAvailability {
        let feature: Feature.Key
        let availability: Feature.Availability
    }

    // Wrapper around the remote configuration service, like e.g. Firebase Remote Config.

    private let featureAvailabilitySubject = PassthroughSubject<FeatureAvailability, Never>()
}

extension DefaultRemoteConfiguration: RemoteConfiguration {

    func availability(for feature: Feature.Key) -> Feature.Availability {
        .available // Return current availability for given feature
    }

    func availabilityPublisher(for feature: Feature.Key) -> AnyPublisher<Feature.Availability, Never> {
        featureAvailabilitySubject
            .filter { featureAvailability in
                featureAvailability.feature == feature
            }
            .map { featureAvailability in
                featureAvailability.availability
            }
            .prepend(.available) // Prepend current availability for give feature
            .eraseToAnyPublisher()
    }

    func networkTimeout() -> Int {
        5
    }

    func supportEmail() -> String {
        "support@email.com"
    }
}
