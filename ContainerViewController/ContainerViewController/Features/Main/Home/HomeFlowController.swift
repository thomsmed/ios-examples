//
//  HomeFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol HomeFlowController: AnyObject {

}

final class DefaultHomeFlowController: UINavigationController {

    private lazy var feedFlowController = DefaultFeedFlowController(
        appDependencies: appDependencies, flowController: self
    )

    private let appDependencies: AppDependencies

    private weak var flowController: MainFlowController?

    init(appDependencies: AppDependencies, flowController: MainFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // setViewControllers([HomeViewController()], animated: false)
        setViewControllers([feedFlowController], animated: false)
    }
}

extension DefaultHomeFlowController: HomeFlowController {

}
