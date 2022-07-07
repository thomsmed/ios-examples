//
//  PurchasesFlowHost+PurchasesFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol PurchasesFlowController: AnyObject {

}

protocol PurchasesFlowHost: PurchasesFlowController & UIViewController {
    func start(_ page: PrimaryScenePage.Main.Activity.Purchases)
    func go(to page: PrimaryScenePage.Main.Activity.Purchases)
}