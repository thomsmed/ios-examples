//
//  DefaultAppFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import Foundation

final class DefaultAppFlowViewFactory {

    internal let appDependencies: AppDependencies

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
}
