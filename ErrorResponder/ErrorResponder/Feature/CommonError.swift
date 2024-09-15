//
//  CommonError.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import Foundation

public enum CommonError: Error {
    case networkTrouble
    case sessionExpired
    case blocked
}
