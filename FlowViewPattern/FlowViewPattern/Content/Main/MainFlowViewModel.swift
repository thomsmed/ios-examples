//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Combine
import SwiftUI

final class MainFlowViewModel: ObservableObject {

    @Published var selectedTab: MainFlowView.Tab = .explore
    @Published var bookingIsPresented: Bool = false
    @Published var greetingIsPresented: Bool = false

    private(set) var currentPage: AppPage.Main

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(
        flowCoordinator: AppFlowCoordinator,
        appDependencies: AppDependencies,
        currentPage: AppPage
    ) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies

        switch currentPage {
        case let .main(page):
            self.currentPage = page
        default:
            self.currentPage = .explore(page: .store(page: .map()))
        }

        let longTimeNoSee = true
        if longTimeNoSee {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.greetingIsPresented = true
            }
        }
    }

    func go(to page: AppPage.Main) {
        currentPage = page

        switch page {
        case .explore:
            selectedTab = .explore
        case .activity:
            selectedTab = .activity
        case .profile:
            selectedTab = .profile
        case .booking:
            bookingIsPresented = true
        }
    }
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        currentPage = .booking(page: .store(details: nil), storeId: "")
        bookingIsPresented = true
    }
}
