//
//  StoreFlowHost+StoreFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol StoreFlowController: AnyObject {
    func goToBooking(with storeInfo: StoreInfo)
}

protocol StoreFlowHost: StoreFlowController & UIViewController {
    func start(_ page: PrimaryPage.Main.Explore.Store)
    func go(to page: PrimaryPage.Main.Explore.Store)
}
