//
//  AppConfiguration.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 14/07/2022.
//

import Foundation

enum Environment: String {
    case test
    case production
}

protocol AppConfiguration: AnyObject {
    var environment: Environment { get }
    var bundleDisplayName: String { get }
    var bundleName: String { get }
    var bundleIdentifier: String { get }
    var bundleShortVersionString: String { get }
    var bundleVersion: String { get }
    var appIdentifierPrefix: String { get }
    var keychainAccessGroup: String { get }
    var keychainService: String { get }
    var keychainAccount: String { get }
    var appGroupIdentifier: String { get }
    var openIdDomain: String { get }
    var openIdClientId: String { get }
    var appUrlScheme: String { get }
}
