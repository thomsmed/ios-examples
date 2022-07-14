//
//  MainFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol MainFlowController: AnyObject {
    func continueToExploreAnd(startAt explorePage: AppPage.Primary.Main.Explore)
    func continueToActivityAnd(startAt activityPage: AppPage.Primary.Main.Activity)
    func continueToProfileAnd(startAt profilePage: AppPage.Primary.Main.Profile)
    func continueToBookingAnd(startAt bookingPage: AppPage.Primary.Main.Booking, with storeId: String, and storeInfo: StoreInfo?)
    func bookingComplete(continueTo activityPage: AppPage.Primary.Main.Activity)
}

protocol MainFlowHost: MainFlowController & UIViewController {
    func start(_ page: AppPage.Primary.Main)
    func go(to page: AppPage.Primary.Main)
}
