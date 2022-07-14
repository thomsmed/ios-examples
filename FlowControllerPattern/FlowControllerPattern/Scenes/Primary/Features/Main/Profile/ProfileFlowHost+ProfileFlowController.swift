//
//  ProfileFlowHost+ProfileFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

protocol ProfileFlowController: AnyObject {

}

protocol ProfileFlowHost: ProfileFlowController & UIViewController {
    func start(_ page: AppPage.Primary.Main.Profile)
    func go(to page: AppPage.Primary.Main.Profile)
}
