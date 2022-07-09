//
//  ActivityFlowHost+ActivityFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol ActivityFlowController: AnyObject {

}

protocol ActivityFlowHost: ActivityFlowController & UIViewController {
    func start(_ page: PrimaryPage.Main.Activity)
    func go(to page: PrimaryPage.Main.Activity)
}
