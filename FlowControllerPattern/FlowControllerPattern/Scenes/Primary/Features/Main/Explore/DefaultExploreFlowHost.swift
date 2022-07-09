//
//  DefaultExploreFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultExploreFlowHost: UINavigationController {

    private weak var flowController: MainFlowController?

    init(flowController: MainFlowController) {
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultExploreFlowHost: ExploreFlowHost {

    func start(_ page: PrimaryPage.Main.Explore) {
        let storesFlowHost = DefaultStoreFlowHost(flowController: self)
        var viewControllers: [UIViewController] = [storesFlowHost]

        switch page {
        case let .store(page):
            storesFlowHost.start(page)
        case .referral:
            storesFlowHost.start(.map())
            viewControllers.append(ReferralViewController())
        }

        setViewControllers(viewControllers, animated: false)
    }

    func go(to page: PrimaryPage.Main.Explore) {
        guard !viewControllers.isEmpty else {
            return start(page)
        }

        switch page {
        case let .store(page):
            guard let storesFlowHost = viewControllers.first as? StoreFlowHost else {
                return start(.store(page: page))
            }

            storesFlowHost.go(to: page)
            setViewControllers([storesFlowHost], animated: true)
        case .referral:
            if viewControllers.count > 1 {
                return
            }

            pushViewController(ReferralViewController(), animated: true)
        }
    }
}

// MARK: ExploreFlowController

extension DefaultExploreFlowHost {

    func continueToBookingAnd(
        startAt bookingPage: PrimaryPage.Main.Booking,
        with storeId: String,
        and storeInfo: StoreInfo?
    ) {
        flowController?.continueToBookingAnd(startAt: bookingPage, with: storeId, and: storeInfo)
    }
}
