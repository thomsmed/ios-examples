//
//  MainFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol MainFlowViewFactory: AnyObject {
    func makeExploreFlowView(with flowCoordinator: MainFlowCoordinator) -> ExploreFlowView
    func makeActivityFlowView() -> ActivityFlowView
    func makeProfileFlowView() -> ProfileFlowView
    func makeBookingFlowView(startingAt path: AppPath.Main.Booking?) -> BookingFlowView
    func makeWelcomeBackView(with flowCoordinator: MainFlowCoordinator) -> WelcomeBackView
}

extension DefaultAppFlowViewFactory: MainFlowViewFactory {
    func makeExploreFlowView(with flowCoordinator: MainFlowCoordinator) -> ExploreFlowView {
        ExploreFlowView(
            flowViewModel: .init(
                flowCoordinator: flowCoordinator
            ),
            flowViewFactory: self
        )
    }

    func makeActivityFlowView() -> ActivityFlowView {
        ActivityFlowView(flowViewModel: .init())
    }

    func makeProfileFlowView() -> ProfileFlowView {
        ProfileFlowView(flowViewModel: .init())
    }

    func makeBookingFlowView(startingAt path: AppPath.Main.Booking?) -> BookingFlowView {
        BookingFlowView()
    }

    func makeWelcomeBackView(with flowCoordinator: MainFlowCoordinator) -> WelcomeBackView {
        WelcomeBackView(viewModel: .init(flowCoordinator: flowCoordinator))
    }
}
