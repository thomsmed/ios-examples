//
//  DefaultBookingFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultBookingFlowHost: UIViewController {

    private let flowFactory: BookingFlowFactory
    private weak var flowController: MainFlowController?

    private var shoppingCart: ShoppingCart?

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal
    )

    init(flowFactory: BookingFlowFactory, flowController: MainFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultBookingFlowHost: BookingFlowHost {

    func start(_ page: AppPage.Primary.Main.Booking, with storeId: String, and storeInfo: StoreInfo?) {
        let shoppingCart = flowFactory.makeShoppingCart()

        let storeViewHolder = flowFactory.makeStoreViewHolder(
            with: self, targeting: page, using: shoppingCart
        )

        pageViewController.setViewControllers(
            [storeViewHolder],
            direction: .forward,
            animated: false
        )

        self.shoppingCart = shoppingCart
    }

    func go(to page: AppPage.Primary.Main.Booking) {

    }
}

// MARK: BookingFlowController

extension DefaultBookingFlowHost {

    func continueToCheckout() {
        guard let shoppingCart = shoppingCart else {
            return
        }

        let checkoutViewHolder = flowFactory.makeCheckoutViewHolder(
            with: self, using: shoppingCart
        )

        pageViewController.setViewControllers(
            [checkoutViewHolder],
            direction: .forward,
            animated: true
        )
    }

    func disableSwipeToDismiss(_ disable: Bool) {
        isModalInPresentation = disable
    }

    func bookingComplete() {
        flowController?.bookingComplete(continueTo: .purchases(page: .active))
    }
}
