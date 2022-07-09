//
//  DefaultBookingFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultBookingFlowHost: UIViewController {

    private let appDependencies: AppDependencies
    private weak var flowController: MainFlowController?

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal
    )

    init(appDependencies: AppDependencies, flowController: MainFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultBookingFlowHost: BookingFlowHost {

    func start(_ page: PrimaryPage.Main.Booking, with storeId: String, and storeInfo: StoreInfo?) {
        let initialServices: [String]
        let initialProducts: [String]
        let goStraightToCheckout: Bool

        switch page {
        case let .home(details):
            initialServices = details.services
            initialProducts = details.products
            goStraightToCheckout = false
        case let .checkout(details):
            initialServices = details.services
            initialProducts = details.products
            goStraightToCheckout = true
        }

        let storeViewController = StoreViewController(
            viewModel: .init(
                appDependencies: appDependencies,
                flowController: self,
                initialServices: initialServices,
                initialProducts: initialProducts,
                goStraightToCheckout: goStraightToCheckout
            )
        )

        pageViewController.setViewControllers(
            [storeViewController],
            direction: .forward,
            animated: false
        )
    }

    func go(to page: PrimaryPage.Main.Booking) {

    }
}

// MARK: BookingFlowController

extension DefaultBookingFlowHost {

    func goToCheckout() {
        pageViewController.setViewControllers(
            [CheckoutViewController()],
            direction: .forward,
            animated: true
        )
    }

    func disableSwipeToDismiss(_ disable: Bool) {
        isModalInPresentation = disable
    }

    func bookingComplete() {
        flowController?.go(to: .purchases(page: .active))
    }
}
