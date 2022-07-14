//
//  DefaultExploreFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultExploreFlowHost: UINavigationController {

    private let flowFactory: ExploreFlowFactory
    private weak var flowController: MainFlowController?

    init(flowFactory: ExploreFlowFactory, flowController: MainFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultExploreFlowHost: ExploreFlowHost {

    func start(_ page: AppPage.Primary.Main.Explore) {
        let storeFlowHost = flowFactory.makeStoreFlowHost(with: self)
        var viewControllers: [UIViewController] = [storeFlowHost]

        switch page {
        case let .store(page):
            storeFlowHost.start(page)
        case .referral:
            storeFlowHost.start(.map())
            viewControllers.append(ReferralViewController())
        }

        setViewControllers(viewControllers, animated: false)
    }

    func go(to page: AppPage.Primary.Main.Explore) {
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

            pushViewController(flowFactory.makeReferralViewHolder(), animated: true)
        }
    }
}

// MARK: ExploreFlowController

extension DefaultExploreFlowHost {

    func continueToBookingAnd(
        startAt bookingPage: AppPage.Primary.Main.Booking,
        with storeId: String,
        and storeInfo: StoreInfo?
    ) {
        flowController?.continueToBookingAnd(startAt: bookingPage, with: storeId, and: storeInfo)
    }
}
