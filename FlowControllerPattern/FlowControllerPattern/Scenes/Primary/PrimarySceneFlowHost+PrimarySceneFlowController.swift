//
//  PrimarySceneFlowHost+PrimarySceneFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol PrimarySceneFlowController: AnyObject {
    func onboardingComplete(continueTo mainPage: AppPage.Primary.Main)
}

protocol PrimarySceneFlowHost: PrimarySceneFlowController & UIViewController {
    func start(_ page: AppPage.Primary)
    func go(to page: AppPage.Primary)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
    func sceneWillEnterForeground()
    func sceneDidEnterBackground()
}
