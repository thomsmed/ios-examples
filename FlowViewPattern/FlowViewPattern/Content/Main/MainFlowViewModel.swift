//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

final class MainFlowViewModel: ObservableObject {

    @Published var selectedTab: MainFlowView.Tab = .explore
    @Published var sheetIsPresented: Bool = false
    @Published var presentedSheet: MainFlowView.PresentedSheet = .none

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: AppFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies

        let longTimeNoSee = true
        if longTimeNoSee {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.presentedSheet = .greeting
                self?.sheetIsPresented = true
            }
        }
    }
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        presentedSheet = .booking
        sheetIsPresented = true
    }
}
