//
//  RemoteConfiguration.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 24/07/2022.
//

import Foundation
import Combine

enum Feature {
    enum Key {
        case favouriteStore
    }

    enum Availability {
        case available
        case unavailable(reason: String)
    }
}

protocol RemoteConfiguration: AnyObject {
    func availability(for feature: Feature.Key) -> Feature.Availability
    func availabilityPublisher(for feature: Feature.Key) -> AnyPublisher<Feature.Availability, Never>
    func networkTimeout() -> Int
    func supportEmail() -> String
}
