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
    var flowHostsByScene: [UIScene: PrimarySceneFlowHost] { get }
    func applicationDidFinishLaunchingWith(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func makeFlowHost(for scene: UIScene) -> PrimarySceneFlowHost
    func discardFlowHost(for scene: UIScene)
}
