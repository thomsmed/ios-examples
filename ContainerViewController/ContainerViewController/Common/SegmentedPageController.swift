//
//  SegmentedPageController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 03/04/2022.
//

import UIKit
import Cartography

class SegmentedPageController: UIViewController {

    private let segmentedControl = UISegmentedControl()

    private var titleObservations = [NSKeyValueObservation]()

    private var segmentedViewControllers = [UIViewController]()

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

    private func removeTitleObservations() {
        titleObservations.forEach { observation in
            observation.invalidate()
        }

        titleObservations.removeAll()
    }

    private func setChildViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        view.addSubview(viewController.view)

        constrain(viewController.view, segmentedControl, view) { child, control, container in
            child.top == control.bottom
            child.leading == container.leading
            child.trailing == container.trailing
            child.bottom == container.bottom
        }

        viewController.didMove(toParent: self)
    }

    private func setSegmentedViewControllers(_ viewControllers: [UIViewController]) {
        removeChildViewControllers()
        removeTitleObservations()
        segmentedControl.removeAllSegments()
        segmentedViewControllers.removeAll()

        viewControllers.enumerated().forEach { index, viewController in

            segmentedControl.insertSegment(withTitle: viewController.title, at: index, animated: false)

            let titleObservation = viewController.observe(\.title) { viewController, _ in
                guard let index = self.segmentedViewControllers.firstIndex(of: viewController) else { return }

                self.segmentedControl.setTitle(viewController.title, forSegmentAt: index)
            }
            titleObservations.append(titleObservation)

            segmentedViewControllers.append(viewController)
        }
    }

    @objc private func segmentChanged(_ target: UISegmentedControl) {
        setChildViewController(segmentedViewControllers[segmentedControl.selectedSegmentIndex])
    }
}

extension SegmentedPageController {

    override func loadView() {
        view = UIView()

        view.addSubview(segmentedControl)

        constrain(segmentedControl, view) { control, container in
            control.top == container.safeAreaLayoutGuide.top
            control.leading == container.safeAreaLayoutGuide.leading
            control.trailing == container.safeAreaLayoutGuide.trailing
            control.bottom <= container.safeAreaLayoutGuide.bottom
        }
    }
}

extension SegmentedPageController {

    var selectedSegmentIndex: Int {
        get {
            return segmentedControl.selectedSegmentIndex
        }
        set {
            guard newValue >= 0, newValue < segmentedControl.numberOfSegments else { return }

            setChildViewController(segmentedViewControllers[newValue])

            segmentedControl.selectedSegmentIndex = newValue
        }
    }

    func setViewControllers(_ viewControllers: [UIViewController], selectedSegmentIndex: Int = 0) {
        setSegmentedViewControllers(viewControllers)

        self.selectedSegmentIndex = selectedSegmentIndex
    }
}
