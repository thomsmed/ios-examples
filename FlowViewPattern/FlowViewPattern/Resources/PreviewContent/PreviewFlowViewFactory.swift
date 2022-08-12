//
//  PreviewFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import Foundation

struct PreviewFlowViewFactory {

    private static let appDependencies = PreviewAppDependencies.shared

    static let shared = DefaultAppFlowViewFactory(appDependencies: appDependencies)

    private init() {}
}
