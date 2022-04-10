//
//  ActivityFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit

protocol ActivityFlowController: AnyObject {

}

final class DefaultActivityFlowController: UINavigationController {

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

        setViewControllers([ActivityViewController()], animated: false)
    }
}

extension DefaultActivityFlowController: ActivityFlowController {
    
}
