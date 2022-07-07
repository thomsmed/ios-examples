//
//  BookingFlowHost+BookingFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol BookingFlowController: AnyObject {

}

protocol BookingFlowHost: BookingFlowController & UIViewController {
    func start(_ page: PrimaryScenePage.Main.Booking, with storeId: String)
    func go(to page: PrimaryScenePage.Main.Booking, with storeId: String)
}
