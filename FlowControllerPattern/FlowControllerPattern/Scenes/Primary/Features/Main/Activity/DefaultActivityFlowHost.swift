//
//  DefaultActivityHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 06/07/2022.
//

import UIKit

final class DefaultActivityFlowHost: UINavigationController {

    private let flowFactory: ActivityFlowFactory
    private weak var flowController: MainFlowController?

    init(flowFactory: ActivityFlowFactory, flowController: MainFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultActivityFlowHost: ActivityFlowHost {

    func start(_ page: PrimaryPage.Main.Activity) {
        
    }

    func go(to page: PrimaryPage.Main.Activity) {

    }
}
