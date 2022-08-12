//
//  MockFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import Foundation

struct MockFlowViewFactory {

    private static let appDependencies = MockAppDependencies.shared

    static let shared = DefaultAppFlowViewFactory(appDependencies: appDependencies)

    private init() {}
}
