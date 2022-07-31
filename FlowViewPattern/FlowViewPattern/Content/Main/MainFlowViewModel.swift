//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

final class MainFlowViewModel: ObservableObject {

    enum Page {
        case explore
        case activity
        case profile
    }

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: AppFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }

    @Published var page: Page = .explore
    @Published var bookingPresented: Bool = false
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        bookingPresented = true
    }
}
