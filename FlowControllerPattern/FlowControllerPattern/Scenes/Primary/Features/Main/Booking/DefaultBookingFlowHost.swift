//
//  DefaultBookingFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultBookingFlowHost: UIViewController {

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal
    )
}

extension DefaultBookingFlowHost: BookingFlowHost {

    func start(_ page: PrimaryScenePage.Main.Booking, with storeId: String) {
        
    }

    func go(to page: PrimaryScenePage.Main.Booking, with storeId: String) {

    }
}
