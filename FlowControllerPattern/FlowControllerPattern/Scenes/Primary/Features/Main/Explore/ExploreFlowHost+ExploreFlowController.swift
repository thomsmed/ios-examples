//
//  ExploreFlowHost+ExploreFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol ExploreFlowController: AnyObject {
    func continueToBookingAnd(startAt bookingPage: AppPage.Primary.Main.Booking, with storeId: String, and storeInfo: StoreInfo?)
}

protocol ExploreFlowHost: ExploreFlowController & UIViewController {
    func start(_ page: AppPage.Primary.Main.Explore)
    func go(to page: AppPage.Primary.Main.Explore)
}
