//
//  MainFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol MainFlowController: AnyObject {
    func go(to page: PrimaryScenePage.Main.Booking, with storeId: String)
}

protocol MainFlowHost: MainFlowController & UIViewController {
    func start(_ page: PrimaryScenePage.Main)
    func go(to page: PrimaryScenePage.Main)
}
