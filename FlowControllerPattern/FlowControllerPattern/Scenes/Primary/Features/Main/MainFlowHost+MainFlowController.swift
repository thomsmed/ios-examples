//
//  MainFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol MainFlowController: AnyObject {
    func continueToExploreAnd(startAt explorePage: PrimaryPage.Main.Explore)
    func continueToActivityAnd(startAt activityPage: PrimaryPage.Main.Activity)
    func continueToProfileAnd(startAt profilePage: PrimaryPage.Main.Profile)
    func continueToBookingAnd(startAt bookingPage: PrimaryPage.Main.Booking, with storeId: String, and storeInfo: StoreInfo?)
    func bookingComplete(continueTo activityPage: PrimaryPage.Main.Activity)
}

protocol MainFlowHost: MainFlowController & UIViewController {
    func start(_ page: PrimaryPage.Main)
    func go(to page: PrimaryPage.Main)
}
