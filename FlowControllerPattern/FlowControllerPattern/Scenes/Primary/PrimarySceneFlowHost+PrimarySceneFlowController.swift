//
//  PrimarySceneFlowHost+PrimarySceneFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol PrimarySceneFlowController: AnyObject {
    func onboardingComplete(continueTo mainPage: PrimaryPage.Main)
}

protocol PrimarySceneFlowHost: PrimarySceneFlowController & UIViewController {
    func start(_ page: PrimaryPage)
    func go(to page: PrimaryPage)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
    func sceneWillEnterForeground()
    func sceneDidEnterBackground()
}
