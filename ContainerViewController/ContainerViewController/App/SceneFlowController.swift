//
//  SceneFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol ViewController where Self: UIViewController { }

protocol SceneFlowControllerFactory: AnyObject {

    func createSceneFlowController() -> SceneFlowController & ViewController
}

protocol SceneFlowController: AnyObject {
    func signedOut()
    func signedIn()
    func completedOnboarding()
}

final class DefaultSceneFlowController: LinearContainerViewController {

    private let appDependencies: AppDependencies

    weak var flowController: AppFlowController?

    private lazy var onboardingFlowController = DefaultOnboardingFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var loginFlowController = DefaultLoginFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var mainFlowController = DefaultMainFlowController(
        appDependencies: appDependencies, flowController: self
    )

    init(appDependencies: AppDependencies, flowController: AppFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewController(onboardingFlowController, using: .none)
    }
}

extension DefaultSceneFlowController: ViewController { }

extension DefaultSceneFlowController: SceneFlowController {

    func signedOut() {
        setViewController(loginFlowController, using: .flip)
    }

    func signedIn() {
        setViewController(mainFlowController, using: .flip)
    }

    func completedOnboarding() {
        setViewController(loginFlowController, using: .dissolve)
    }
}
