//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI
import Combine

final class MainFlowViewModel: ObservableObject {

    @Published var selectedTab: MainFlowView.Tab = .explore
    @Published var bookingIsPresented: Bool = false
    @Published var greetingIsPresented: Bool = false

    private(set) var currentMainPage: AppPage.Main {
        didSet {
            mainPageSubject.send(currentMainPage)
        }
    }

    private let mainPageSubject = PassthroughSubject<AppPage.Main, Never>()

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    private var appPageSubscription: AnyCancellable?

    init(
        flowCoordinator: AppFlowCoordinator,
        appDependencies: AppDependencies
    ) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies

        switch flowCoordinator.currentAppPage {
        case let .main(page):
            self.currentMainPage = page
        default:
            self.currentMainPage = .explore(page: .store(page: .map()))

            let longTimeNoSee = true
            if longTimeNoSee {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.greetingIsPresented = true
                }
            }
        }

        appPageSubscription = flowCoordinator.appPage
            .compactMap { appPage in
                if case let .main(mainPage) = appPage {
                    return mainPage
                }
                return nil
            }
            .sink { [weak self] mainPage in
                self?.currentMainPage = mainPage

                switch mainPage {
                case .explore:
                    self?.selectedTab = .explore
                case .activity:
                    self?.selectedTab = .activity
                case .profile:
                    self?.selectedTab = .profile
                case .booking:
                    self?.bookingIsPresented = true
                }
            }
    }
}

extension MainFlowViewModel: MainFlowCoordinator {

    var mainPage: AnyPublisher<AppPage.Main, Never> {
        mainPageSubject.eraseToAnyPublisher()
    }

    func presentBooking() {
        currentMainPage = .booking(page: .store(details: nil), storeId: "")
        bookingIsPresented = true
    }
}
