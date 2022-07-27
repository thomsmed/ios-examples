//
//  DefaultAppConfiguration.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 14/07/2022.
//

import Foundation

final class DefaultAppConfiguration {

    private enum DistributionPlatform {
        case appStore
        case testFlight
        case debug
    }

    private var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    private var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }

    private lazy var distributionPlatform: DistributionPlatform = {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }()

    private lazy var mainInfoDictionary: [String: Any] = {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Somehow failed to load the content of Info.plist")
        }
        return infoDictionary
    }()

    private lazy var authInfoDictionary: [String: Any] = {
        guard
            let path = Bundle.main.path(forResource: "Auth", ofType: "plist"),
            let data = FileManager.default.contents(atPath: path),
            let infoDictionary = try? PropertyListSerialization.propertyList(
                from: data,
                options: .mutableContainers,
                format: nil
            ) as? [String: String]
        else {
            fatalError("Somehow failed to load the content of Auth.plist")
        }
        return infoDictionary
    }()

    private lazy var firstUrlScheme: String = {
        guard
            let urlTypes = mainInfoDictionary["CFBundleURLTypes"] as? [[String: Any]],
            let firstUrlType = urlTypes.first,
            let urlSchemes = firstUrlType["CFBundleURLSchemes"] as? [String],
            let firstUrlScheme = urlSchemes.first
        else {
            fatalError("No URL Schemes in Info.plist")
        }
        return firstUrlScheme
    }()

    private func value(for key: String) -> String {
        guard
            let value = mainInfoDictionary[key] as? String,
            !value.isEmpty
        else {
            fatalError("No \(key) in Info.plist")
        }
        return value
    }

    private func authValue(for key: String) -> String {
        guard
            let value = authInfoDictionary[key] as? String,
            !value.isEmpty
        else {
            fatalError("No \(key) in Auth.plist")
        }
        return value
    }
}

// MARK: AppConfiguration

extension DefaultAppConfiguration: AppConfiguration {
    var environment: Environment {
        // move .testFlight to the desired environment depending on test case
        switch distributionPlatform {
        case .appStore, .testFlight:
            return .production
        case .debug:
            return .test
        }
    }
    var bundleDisplayName: String { value(for: "CFBundleDisplayName") }
    var bundleName: String { value(for: "CFBundleName") }
    var bundleIdentifier: String { value(for: "CFBundleIdentifier") }
    var bundleShortVersionString: String { value(for: "CFBundleShortVersionString") }
    var bundleVersion: String { value(for: "CFBundleVersion") }
    var appIdentifierPrefix: String { value(for: "AppIdentifierPrefix") }
    var keychainAccessGroup: String { "\(appIdentifierPrefix)\(bundleIdentifier)" }
    var keychainService: String { bundleIdentifier }
    var keychainAccount: String { bundleName }
    var appGroupIdentifier: String { "group.\(bundleIdentifier)" }
    var openIdDomain: String { authValue(for: "Domain") }
    var openIdClientId: String { authValue(for: "ClientId") }
    var appUrlScheme: String { firstUrlScheme }
}
