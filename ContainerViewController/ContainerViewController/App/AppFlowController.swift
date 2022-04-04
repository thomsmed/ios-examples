//
//  AppFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 04/04/2022.
//

import UIKit

protocol AppFlowController: AnyObject {

}

final class DefaultAppFlowController {

    private let appDependencies: AppDependencies

    private lazy var sceneFlowController = DefaultSceneFlowController(
        appDependencies: appDependencies, flowController: self
    )

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies

        configureAppearance()
    }

    private func configureAppearance() {
        UINavigationBar.appearance().tintColor = .label
        UITabBar.appearance().tintColor = .label
        UIButton.appearance().tintColor = .label
    }
}

extension DefaultAppFlowController: AppFlowController {

}

extension DefaultAppFlowController: SceneFlowControllerFactory {

    func createSceneFlowController() -> SceneFlowController & ViewController {
        sceneFlowController
    }
}
