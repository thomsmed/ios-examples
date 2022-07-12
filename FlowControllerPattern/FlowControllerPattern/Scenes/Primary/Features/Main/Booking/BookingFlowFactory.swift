//
//  BookingFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol BookingFlowFactory: AnyObject {
    func makeShoppingCart() -> ShoppingCart
    func makeStoreViewHolder(
        with flowController: BookingFlowController,
        targeting page: PrimaryPage.Main.Booking,
        using shoppingCart: ShoppingCart
    ) -> StoreViewHolder
    func makeCheckoutViewHolder(
        with flowController: BookingFlowController,
        using shoppingCart: ShoppingCart
    ) -> CheckoutViewHolder
}

extension DefaultAppFlowFactory: BookingFlowFactory {

    func makeShoppingCart() -> ShoppingCart {
        ShoppingCart()
    }

    func makeStoreViewHolder(
        with flowController: BookingFlowController,
        targeting page: PrimaryPage.Main.Booking,
        using shoppingCart: ShoppingCart
    ) -> StoreViewHolder {
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

        return StoreViewController(
            viewModel: .init(
                flowController: flowController,
                storeService: appDependencies.storeService,
                shoppingCart: shoppingCart,
                initialServices: initialServices,
                initialProducts: initialProducts,
                goStraightToCheckout: goStraightToCheckout
            )
        )
    }

    func makeCheckoutViewHolder(
        with flowController: BookingFlowController,
        using shoppingCart: ShoppingCart
    ) -> CheckoutViewHolder {
        CheckoutViewController(
            viewModel: .init(
                flowController: flowController,
                bookingService: appDependencies.bookingService,
                shoppingCart: shoppingCart
            )
        )
    }
}
