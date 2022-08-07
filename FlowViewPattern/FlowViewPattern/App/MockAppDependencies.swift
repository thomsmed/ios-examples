//
//  MockAppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class MockAppDependencies {

    static let shared: AppDependencies = MockAppDependencies()

    let defaultsRepository: DefaultsRepository

    private init() {
        defaultsRepository = DefaultDefaultsRepository() // TODO: Mock this (and rename from Dummy... to Mock...)
    }
}

extension MockAppDependencies: AppDependencies {

}
