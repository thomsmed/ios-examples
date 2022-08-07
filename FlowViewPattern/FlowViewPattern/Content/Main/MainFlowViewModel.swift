//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

final class MainFlowViewModel: ObservableObject {

    enum PresentedSheet {
        case none
        case booking
    }

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(flowCoordinator: AppFlowCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies
    }

    @Published var presentedSheet: PresentedSheet = .none

    func presentedSheetDismissed() {
        presentedSheet = .none
    }
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        presentedSheet = .booking
    }
}

extension MainFlowViewModel: MainFlowViewFactory {

    func makeExploreFlowView() -> ExploreFlowView {
        ExploreFlowView(flowViewModel: .init(flowCoordinator: self))
    }

    func makeActivityFlowView() -> ActivityFlowView {
        ActivityFlowView(flowViewModel: .init())
    }

    func makeProfileFlowView() -> ProfileFlowView {
        ProfileFlowView()
    }

    func makeBookingFlowView() -> BookingFlowView {
        BookingFlowView()
    }
}
