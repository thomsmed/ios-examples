//
//  AppFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class AppFlowViewModel: ObservableObject {

    private let appDependencies: AppDependencies

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
}

extension AppFlowViewModel: AppFlowCoordinator {
    
}
