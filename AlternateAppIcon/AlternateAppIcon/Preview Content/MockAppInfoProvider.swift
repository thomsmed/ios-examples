//
//  MockAppInfoProvider.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import Foundation

final class MockAppInfoProvider: AppInfoProvider {
    var bundleName: String = ""
    var bundleDisplayName: String = ""
    var bundleIdentifier: String = ""
    var bundleShortVersionString: String = ""
    var bundleVersion: String = ""
    var primaryAppIconName: String = ""
    var alternateAppIconNames: [String] = []
}
