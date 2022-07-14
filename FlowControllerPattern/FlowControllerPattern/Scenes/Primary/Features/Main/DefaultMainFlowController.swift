//
//  DefaultMainFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultMainFlowHost: UITabBarController {

    private let flowFactory: MainFlowFactory

    private var exploreFlowHost: ExploreFlowHost?
    private var activityFlowHost: ActivityFlowHost?
    private var profileFlowHost: ProfileFlowHost?

    init(flowFactory: MainFlowFactory) {
        self.flowFactory = flowFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultMainFlowHost: MainFlowHost {

    func start(_ page: AppPage.Primary.Main) {
        let exploreFlowHost = flowFactory.makeExploreFlowHost(with: self)
        let activityFlowHost = flowFactory.makeActivityFlowHost(with: self)
        let profileFlowHost = flowFactory.makeProfileFlowHost(with: self)

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

    func go(to page: AppPage.Primary.Main) {
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
                let bookingFlowHost = self.flowFactory.makeBookingFlowHost(with: self)
                bookingFlowHost.start(page, with: storeId, and: storeInfo)
                self.present(bookingFlowHost, animated: true)
            }
        }
    }
}

// MARK: MainFlowController

extension DefaultMainFlowHost {

    func continueToExploreAnd(startAt explorePage: AppPage.Primary.Main.Explore) {
        selectedIndex = 0
        exploreFlowHost?.go(to: explorePage)
    }

    func continueToActivityAnd(startAt activityPage: AppPage.Primary.Main.Activity) {
        selectedIndex = 1
        activityFlowHost?.go(to: activityPage)
    }

    func continueToProfileAnd(startAt profilePage: AppPage.Primary.Main.Profile) {
        selectedIndex = 2
        profileFlowHost?.go(to: profilePage)
    }

    func continueToBookingAnd(
        startAt bookingPage: AppPage.Primary.Main.Booking,
        with storeId: String,
        and storeInfo: StoreInfo?
    ) {
        dismiss(animated: false) {
            let bookingFlowHost = self.flowFactory.makeBookingFlowHost(with: self)
            bookingFlowHost.start(bookingPage, with: storeId, and: storeInfo)
            self.present(bookingFlowHost, animated: true)
        }
    }

    func bookingComplete(continueTo activityPage: AppPage.Primary.Main.Activity) {
        dismiss(animated: true) {
            self.selectedIndex = 1
            self.activityFlowHost?.go(to: activityPage)
        }
    }
}
