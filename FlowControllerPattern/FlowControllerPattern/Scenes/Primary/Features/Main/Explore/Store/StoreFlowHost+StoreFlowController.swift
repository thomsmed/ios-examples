//
//  StoreFlowHost+StoreFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol StoreFlowController: AnyObject {

}

protocol StoreFlowHost: StoreFlowController & UIViewController {
    func start(_ page: PrimaryScenePage.Main.Explore.Store)
    func go(to page: PrimaryScenePage.Main.Explore.Store)
}
