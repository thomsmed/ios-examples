//
//  DefaultStoreFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultStoreFlowHost: SinglePageController {

    private let flowFactory: StoreFlowFactory
    private weak var flowController: ExploreFlowController?

    private var storeMapViewHolder: StoreMapViewHolder?
    private var storeListViewHolder: StoreListViewHolder?

    init(flowFactory: StoreFlowFactory, flowController: ExploreFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultStoreFlowHost: StoreFlowHost {

    func start(_ page: AppPage.Primary.Main.Explore.Store) {
        switch page {
        case let .map(bookingPage, storeId):
            let storeMapViewHolder = flowFactory.makeStoreMapViewHolder()

            setViewController(storeMapViewHolder, using: .dissolve)

            self.storeMapViewHolder = storeMapViewHolder

            guard let storeId = storeId else {
                return
            }

            storeMapViewHolder.selectStore(with: storeId)

            guard let bookingPage = bookingPage else {
                return
            }

            flowController?.continueToBookingAnd(startAt: bookingPage, with: storeId, and: nil)
        case .list:
            let storeListViewHolder = flowFactory.makeStoreListViewHolder(with: self)

            setViewController(storeListViewHolder, using: .dissolve)

            self.storeListViewHolder = storeListViewHolder
        }
    }

    func go(to page: AppPage.Primary.Main.Explore.Store) {
        switch page {
        case let .map(bookingPage, storeId):
            guard let storeMapViewHolder = self.storeMapViewHolder else {
                return start(page)
            }

            setViewController(storeMapViewHolder, using: .dissolve)

            guard let storeId = storeId else {
                return
            }

            storeMapViewHolder.selectStore(with: storeId)

            guard let bookingPage = bookingPage else {
                return
            }

            flowController?.continueToBookingAnd(startAt: bookingPage, with: storeId, and: nil)
        case .list:
            guard let storeListViewHolder = self.storeListViewHolder else {
                return start(page)
            }

            setViewController(storeListViewHolder, using: .dissolve)
        }
    }
}

// MARK: StoreFlowController

extension DefaultStoreFlowHost {

    func selectStoreFilterOptions(_ completion: @escaping (StoreFlow.FilterOptions) -> Void) {
        let storeFilterSheetHolder = flowFactory.makeStoreFilterSheetHolder(passing: completion)
        present(storeFilterSheetHolder, animated: true)
    }

    func continueToBooking(with storeInfo: StoreInfo) {
        flowController?.continueToBookingAnd(
            startAt: .checkout(details: .init(services: [], products: [])),
            with: storeInfo.id,
            and: storeInfo
        )
    }
}
