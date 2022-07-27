//
//  SegmentedPageController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

class SegmentedPageController: UIViewController {

    private let segmentedControl = UISegmentedControl()

    private var segmentedViewControllers = [UIViewController]()

    override func loadView() {
        view = UIView()

        view.addSubview(segmentedControl)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        segmentedControl.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            segmentedControl.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            segmentedControl.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            segmentedControl.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func removeChildViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)

            viewController.view.removeFromSuperview()

            viewController.removeFromParent()
        }
    }

    private func setChildViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        view.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.setContentHuggingPriority(.defaultLow, for: .vertical)
        viewController.view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
    }

    private func setSegmentedViewControllers(_ viewControllers: [UIViewController]) {
        removeChildViewControllers()
        segmentedControl.removeAllSegments()
        segmentedViewControllers.removeAll()

        viewControllers.enumerated().forEach { index, viewController in
            segmentedControl.insertSegment(withTitle: viewController.title, at: index, animated: false)
            segmentedViewControllers.append(viewController)
        }
    }

    @objc private func segmentChanged(_ target: UISegmentedControl) {
        setChildViewController(segmentedViewControllers[segmentedControl.selectedSegmentIndex])
    }
}

extension SegmentedPageController {

    var selectedSegmentIndex: Int {
        get {
            return segmentedControl.selectedSegmentIndex
        }
        set {
            guard newValue >= 0, newValue < segmentedControl.numberOfSegments else { return }

            segmentedControl.selectedSegmentIndex = newValue

            setChildViewController(segmentedViewControllers[newValue])
        }
    }

    func setViewControllers(_ viewControllers: [UIViewController], selectedSegmentIndex: Int = 0) {
        setSegmentedViewControllers(viewControllers)

        self.selectedSegmentIndex = selectedSegmentIndex
    }

    func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any], for state: UIControl.State) {
        segmentedControl.setTitleTextAttributes(attributes, for: state)
    }
}

