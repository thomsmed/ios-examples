//
//  MainFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol MainFlowController: AnyObject {
    func signedOut()
}

final class DefaultMainFlowController: UITabBarController {

    private let appDependencies: AppDependencies

    weak var flowController: AppFlowController?

    private lazy var homeFlowController = DefaultHomeFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var activityFlowController = DefaultActivityFlowController(
        appDependencies: appDependencies, flowController: self
    )
    private lazy var profileFlowController = DefaultProfileFlowController(
        appDependencies: appDependencies, flowController: self
    )

    init(appDependencies: AppDependencies, flowController: AppFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        homeFlowController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        activityFlowController.tabBarItem = UITabBarItem(title: "Activity", image: UIImage(systemName: "list.star"), tag: 2)
        profileFlowController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)

        setViewControllers([
            homeFlowController,
            activityFlowController,
            profileFlowController
        ], animated: false)

        selectedIndex = 0
    }
}

extension DefaultMainFlowController: MainFlowController {

    func signedOut() {
        flowController?.signedOut()
    }
}
