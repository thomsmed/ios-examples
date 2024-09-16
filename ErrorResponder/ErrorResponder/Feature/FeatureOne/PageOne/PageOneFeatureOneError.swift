//
//  PageOneFeatureOneError.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

enum PageOneFeatureOneError: Error {
    case wrongInput
    case needsConfirmation
    case feature(FeatureOneError)
    case common(CommonError)
}
