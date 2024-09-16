//
//  FeatureTwoError.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

enum FeatureTwoError: Error {
    case blocked
    case common(CommonError)
}
