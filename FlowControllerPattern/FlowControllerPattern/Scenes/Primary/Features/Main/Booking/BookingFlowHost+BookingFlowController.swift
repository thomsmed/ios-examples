//
//  BookingFlowHost+BookingFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol BookingFlowController: AnyObject {
    func continueToCheckout()
    func disableSwipeToDismiss(_ disable: Bool)
    func bookingComplete()
}

protocol BookingFlowHost: BookingFlowController & UIViewController {
    func start(_ page: AppPage.Primary.Main.Booking, with storeId: String, and storeInfo: StoreInfo?)
    func go(to page: AppPage.Primary.Main.Booking)
}
