//
//  MainFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol MainFlowController: AnyObject {
    func go(to page: PrimaryPage.Main.Explore)
    func go(to page: PrimaryPage.Main.Activity)
    func go(to page: PrimaryPage.Main.Profile)
    func go(to page: PrimaryPage.Main.Booking, with storeId: String, and storeInfo: StoreInfo?)
}

protocol MainFlowHost: MainFlowController & UIViewController {
    func start(_ page: PrimaryPage.Main)
    func go(to page: PrimaryPage.Main)
}
