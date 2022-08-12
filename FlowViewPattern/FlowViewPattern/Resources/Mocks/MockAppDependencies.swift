//
//  MockAppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class MockAppDependencies: AppDependencies {

    static let shared: AppDependencies = MockAppDependencies()

    let defaultsRepository: DefaultsRepository

    private init() {
        defaultsRepository = UserDefaultsDefaultsRepository()
    }
}
