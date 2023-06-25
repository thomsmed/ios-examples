//
//  MockDependencies.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import Foundation

final class MockDependencies: Dependencies {
    let application: Application = MockApplication()
    let appInfoProvider: AppInfoProvider = MockAppInfoProvider()

    private init() {}
}

extension MockDependencies {
    static let shared = MockDependencies()
}
