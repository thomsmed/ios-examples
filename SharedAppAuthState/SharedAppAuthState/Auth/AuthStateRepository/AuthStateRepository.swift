//
//  AuthStateRepository.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import AppAuth

protocol AuthStateRepository: AnyObject {
    var state: OIDAuthState? { get }
    func persist(state: OIDAuthState) throws
    func clear()
}
