//
//  DefaultAppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class DefaultAppDependencies: AppDependencies {

    let defaultsRepository: DefaultsRepository

    init() {
        defaultsRepository = UserDefaultsDefaultsRepository()
    }
}
