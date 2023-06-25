//
//  AppInfoProvider.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import Foundation

protocol AppInfoProvider: AnyObject {
    var bundleName: String { get }
    var bundleDisplayName: String { get }
    var bundleIdentifier: String { get }
    var bundleShortVersionString: String { get }
    var bundleVersion: String { get }
    var primaryAppIconName: String { get }
    var alternateAppIconNames: [String] { get }
}

final class DefaultAppInfoProvider: AppInfoProvider {
    private func getValue<Value>(for key: String) -> Value {
        guard
            let value = Bundle.main.infoDictionary?[key] as? Value
        else {
            fatalError("Missing value for \(key) in Info.plist")
        }
        return value
    }

    private func getPrimaryAppIconName() -> String {
        let appIconsDict: [String: [String: Any]] = getValue(for: "CFBundleIcons")

        let primaryIconDict = appIconsDict["CFBundlePrimaryIcon"]

        guard let primaryIconName = primaryIconDict?["CFBundleIconName"] as? String else {
            fatalError("Missing primary icon name")
        }

        return primaryIconName
    }

    private func getAlternateAppIconNames() -> [String] {
        let appIconsDict: [String: [String: Any]] = getValue(for: "CFBundleIcons")

        let alternateIconsDict = appIconsDict["CFBundleAlternateIcons"] as? [String: [String: String]]

        var alternateAppIconNames = [String]()

        alternateIconsDict?.forEach { _, value in
            if let alternateIconName = value["CFBundleIconName"] {
                alternateAppIconNames.append(alternateIconName)
            }
        }

        return alternateAppIconNames
    }

    private lazy var documentDirectoryPath: URL = {
        guard
            let documentDirectoryPath = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            fatalError("Could not find path to Document directory")
        }
        return documentDirectoryPath
    }()

    lazy var bundleName: String = getValue(for: "CFBundleName")
    lazy var bundleDisplayName: String = getValue(for: "CFBundleDisplayName")
    lazy var bundleIdentifier: String = getValue(for: "CFBundleIdentifier")
    lazy var bundleShortVersionString: String = getValue(for: "CFBundleShortVersionString")
    lazy var bundleVersion: String = getValue(for: "CFBundleVersion")
    lazy var primaryAppIconName: String = getPrimaryAppIconName()
    lazy var alternateAppIconNames: [String] = getAlternateAppIconNames()
}
