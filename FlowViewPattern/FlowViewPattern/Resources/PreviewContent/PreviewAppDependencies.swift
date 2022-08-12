//
//  PreviewAppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class PreviewAppDependencies: AppDependencies {

    static let shared: AppDependencies = PreviewAppDependencies()

    let defaultsRepository: DefaultsRepository

    private init() {
        defaultsRepository = UserDefaultsDefaultsRepository()
    }
}
