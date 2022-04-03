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

    private let appDependencies: AppDependencies

    weak var flowController: MainFlowController?

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

        setViewControllers([HomeViewController()], animated: false)
    }
}

extension DefaultHomeFlowController: HomeFlowController {

}
