//
//  DefaultMainFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultMainFlowHost: UITabBarController {

    private let appDependencies: AppDependencies

    private var exploreFlowHost: ExploreFlowHost?
    private var activityFlowHost: ActivityFlowHost?
    private var profileFlowHost: ProfileFlowHost?

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultMainFlowHost: MainFlowHost {

    func start(_ page: PrimaryScenePage.Main) {
        let exploreFlowHost = DefaultExploreFlowHost(flowController: self)
        let activityFlowHost = DefaultActivityFlowHost()
        let profileFlowHost = DefaultProfileFlowHost()

        setViewControllers([
            exploreFlowHost,
            activityFlowHost,
            profileFlowHost
        ], animated: false)

        switch page {
        case let .explore(page):
            selectedIndex = 0
            exploreFlowHost.start(page)
        case let .activity(page):
            selectedIndex = 1
            activityFlowHost.start(page)
        case let .profile(page):
            selectedIndex = 2
            profileFlowHost.start(page)
        default:
            selectedIndex = 0
            exploreFlowHost.start(.store(page: .map()))
        }

        self.exploreFlowHost = exploreFlowHost
        self.activityFlowHost = activityFlowHost
        self.profileFlowHost = profileFlowHost
    }

    func go(to page: PrimaryScenePage.Main) {
        guard viewControllers?.isEmpty == false else {
            return start(page)
        }

        switch page {
        case let .explore(page):
            selectedIndex = 0
            exploreFlowHost?.go(to: page)
        case let .activity(page):
            selectedIndex = 1
            activityFlowHost?.go(to: page)
        case let .profile(page):
            selectedIndex = 2
            profileFlowHost?.go(to: page)
        case let .booking(page, storeId, storeInfo):
            dismiss(animated: false) {
                let bookingFlowHost = DefaultBookingFlowHost(
                    appDependencies: self.appDependencies, flowController: self
                )
                bookingFlowHost.start(page, with: storeId, and: storeInfo)
                self.present(bookingFlowHost, animated: true)
            }
        }
    }
}

// MARK: MainFlowController

extension DefaultMainFlowHost {

    func go(to page: PrimaryScenePage.Main.Explore) {
        selectedIndex = 0
        exploreFlowHost?.go(to: page)
    }

    func go(to page: PrimaryScenePage.Main.Activity) {
        selectedIndex = 1
        activityFlowHost?.go(to: page)
    }

    func go(to page: PrimaryScenePage.Main.Profile) {
        selectedIndex = 2
        profileFlowHost?.go(to: page)
    }

    func go(to page: PrimaryScenePage.Main.Booking, with storeId: String, and storeInfo: StoreInfo?) {
        dismiss(animated: false) {
            let bookingFlowHost = DefaultBookingFlowHost(
                appDependencies: self.appDependencies, flowController: self
            )
            bookingFlowHost.start(page, with: storeId, and: storeInfo)
            self.present(bookingFlowHost, animated: true)
        }
    }
}
