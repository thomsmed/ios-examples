//
//  PrimarySceneFlowHost+PrimarySceneFlowController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

protocol PrimarySceneFlowController: AnyObject {

}

protocol PrimarySceneFlowHost: PrimarySceneFlowController & UIViewController {
    func start(_ page: PrimaryScenePage)
    func go(to page: PrimaryScenePage)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
    func sceneWillEnterForeground()
    func sceneDidEnterBackground()
    func open(_ urlContexts: Set<UIOpenURLContext>)
}
