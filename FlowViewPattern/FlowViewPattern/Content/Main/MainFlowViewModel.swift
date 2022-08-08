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
        case greeting
    }

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

    @Published var sheetIsPresented: Bool = false
    @Published var presentedSheet: PresentedSheet = .none
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        presentedSheet = .booking
        sheetIsPresented = true
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

    func makeWelcomeBackView() -> WelcomeBackView {
        WelcomeBackView(viewModel: .init(flowCoordinator: self))
    }
}
