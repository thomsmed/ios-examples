//
//  FeedFlowController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 03/04/2022.
//

import UIKit

protocol FeedFlowController {

}

final class DefaultFeedFlowController: SegmentedPageController {

    private let appDependencies: AppDependencies

    private weak var flowController: HomeFlowController?

    init(appDependencies: AppDependencies, flowController: HomeFlowController) {
        self.appDependencies = appDependencies
        self.flowController = flowController

        super.init(nibName: nil, bundle: nil)

        title = "Feed"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        setViewControllers([NewsViewController(), PopularViewController()])
    }
}

extension DefaultFeedFlowController: FeedFlowController {

}
