//
//  AppFlowHost+AppFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol AppFlowController: AnyObject {

}

protocol AppFlowHost: AppFlowController {
    func applicationDidFinishLaunchingWith(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func flowHost(for scene: UIScene) -> PrimarySceneFlowHost
    func discardFlowHost(for scene: UIScene)
    func go(to page: AppPage)
}
