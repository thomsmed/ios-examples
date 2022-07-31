//
//  DummyAppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class DummyAppDependencies {

    private init() { }
}

extension DummyAppDependencies: AppDependencies {

    static let shared: AppDependencies = DummyAppDependencies()
}
