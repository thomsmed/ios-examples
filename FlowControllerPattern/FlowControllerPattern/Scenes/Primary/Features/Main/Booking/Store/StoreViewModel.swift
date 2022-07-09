//
//  StoreViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 08/07/2022.
//

import Foundation

final class StoreViewModel {

    private weak var flowController: BookingFlowController?

    private let storeService: StoreService
    private let shoppingCart: ShoppingCart

    init(
        flowController: BookingFlowController,
        storeService: StoreService,
        shoppingCart: ShoppingCart,
        initialServices: [String],
        initialProducts: [String],
        goStraightToCheckout: Bool
    ) {
        self.flowController = flowController
        self.storeService = storeService
        self.shoppingCart = shoppingCart
    }
}
