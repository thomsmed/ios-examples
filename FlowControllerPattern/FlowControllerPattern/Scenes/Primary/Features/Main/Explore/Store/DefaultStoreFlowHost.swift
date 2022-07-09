//
//  DefaultStoreFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultStoreFlowHost: SinglePageController {

    private weak var flowController: ExploreFlowController?

    private var storeMapViewController: StoreMapViewController?
    private var storeListViewController: StoreListViewController?

    init(flowController: ExploreFlowController) {
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultStoreFlowHost: StoreFlowHost {

    func start(_ page: PrimaryPage.Main.Explore.Store) {
        switch page {
        case let .map(bookingPage, storeId):
            let storeMapViewController = StoreMapViewController()

            setViewController(storeMapViewController, using: .dissolve)

            self.storeMapViewController = storeMapViewController

            guard let storeId = storeId else {
                return
            }

            storeMapViewController.selectStore(with: storeId)

            guard let bookingPage = bookingPage else {
                return
            }

            flowController?.go(to: bookingPage, with: storeId, and: nil)
        case .list:
            let storeListViewController = StoreListViewController()

            setViewController(storeListViewController, using: .dissolve)

            self.storeListViewController = storeListViewController
        }
    }

    func go(to page: PrimaryPage.Main.Explore.Store) {
        switch page {
        case let .map(bookingPage, storeId):
            guard let storeMapViewController = self.storeMapViewController else {
                return start(page)
            }

            setViewController(storeMapViewController, using: .dissolve)

            guard let storeId = storeId else {
                return
            }

            storeMapViewController.selectStore(with: storeId)

            guard let bookingPage = bookingPage else {
                return
            }

            flowController?.go(to: bookingPage, with: storeId, and: nil)
        case .list:
            guard let storeListViewController = self.storeListViewController else {
                return start(page)
            }

            setViewController(storeListViewController, using: .dissolve)
        }
    }
}

// MARK: StoreFlowController

extension DefaultStoreFlowHost {

    func goToBooking(with storeInfo: StoreInfo) {
        flowController?.go(
            to: .checkout(
                details: .init(services: [], products: [])
            ),
            with: storeInfo.id,
            and: storeInfo
        )
    }
}
