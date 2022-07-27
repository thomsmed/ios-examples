//
//  CheckoutViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

final class CheckoutViewModel {

    private weak var flowController: BookingFlowController?

    private let bookingService: BookingService
    private let shoppingCart: ShoppingCart

    init(
        flowController: BookingFlowController,
        bookingService: BookingService,
        shoppingCart: ShoppingCart
    ) {
        self.flowController = flowController
        self.bookingService = bookingService
        self.shoppingCart = shoppingCart
    }
}
