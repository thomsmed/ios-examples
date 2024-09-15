//
//  PageOneFeatureTwoError.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

enum PageOneFeatureTwoError: Error {
    case wrongInput
    case needsConfirmation
    case feature(FeatureTwoError)
    case common(CommonError)
}
