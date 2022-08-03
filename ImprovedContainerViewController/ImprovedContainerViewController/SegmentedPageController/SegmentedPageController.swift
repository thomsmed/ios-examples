//
//  SegmentedPageViewController.swift
//  ImprovedContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/08/2022.
//

import UIKit

class SegmentedPageController: UIViewController {

    private let segmentedControl = UISegmentedControl()

    private var titleObservations = [NSKeyValueObservation]()

    private var segmentedViewControllers = [UIViewController]()

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false // Override this when animating views using constraints
    }

    override func loadView() {
        view = UIView()

        view.addSubview(segmentedControl)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.setContentHuggingPriority(.required, for: .vertical)
        segmentedControl.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedViewController?.endAppearanceTransition()
    }

    private var isCurrentlyVisible: Bool {
        viewIfLoaded?.window != nil
    }

    private func addAndConstraint(visibleViewControllerView: UIView) {
        view.addSubview(visibleViewControllerView)
        
        visibleViewControllerView.translatesAutoresizingMaskIntoConstraints = false

        visibleViewControllerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        visibleViewControllerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        NSLayoutConstraint.activate([
            visibleViewControllerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            visibleViewControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visibleViewControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visibleViewControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        visibleViewControllerView.layoutIfNeeded()
    }

    private func removeChildViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)

            if isCurrentlyVisible {
                viewController.beginAppearanceTransition(false, animated: false)
                viewController.endAppearanceTransition()
            }

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

    private func setVisibleViewController(_ visibleViewController: UIViewController) {
        removeChildViewControllers()

        addChild(visibleViewController)

        addAndConstraint(visibleViewControllerView: visibleViewController.view)

        if isCurrentlyVisible {
            visibleViewController.beginAppearanceTransition(true, animated: false)
            visibleViewController.endAppearanceTransition()
        }

        visibleViewController.didMove(toParent: self)
    }

    private func slideLeftTransition(to viewController: UIViewController) {

    }

    private func slideRightTransition(to viewController: UIViewController) {

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
        setVisibleViewController(segmentedViewControllers[segmentedControl.selectedSegmentIndex])
    }
}

extension SegmentedPageController {

    enum Transition {
        case none
        case slide
    }

    var viewControllers: [UIViewController] {
        get {
            segmentedViewControllers
        }
        set {
            setSegmentedViewControllers(newValue)
        }
    }

    var selectedViewController: UIViewController? {
        children.first
    }

    var selectedSegmentIndex: Int {
        get {
            return segmentedControl.selectedSegmentIndex
        }
        set {
            guard newValue >= 0, newValue < segmentedControl.numberOfSegments else { return }

            segmentedControl.selectedSegmentIndex = newValue

            setVisibleViewController(segmentedViewControllers[newValue])
        }
    }

    func setSelectedSegmentIndex(_ index: Int, using transition: Transition) {
        guard index >= 0, index < segmentedControl.numberOfSegments else { return }

        let slideRight = index < segmentedControl.selectedSegmentIndex

        segmentedControl.selectedSegmentIndex = index

        guard isCurrentlyVisible else {
            return setVisibleViewController(segmentedViewControllers[index])
        }

        switch transition {
        case .none:
            setVisibleViewController(segmentedViewControllers[index])
        case .slide:
            if slideRight {
                slideRightTransition(to: segmentedViewControllers[index])
            } else {
                slideLeftTransition(to: segmentedViewControllers[index])
            }
        }
    }

    func setViewControllers(_ viewControllers: [UIViewController], using transition: Transition) {
        setSegmentedViewControllers(viewControllers)

        guard let firstViewController = viewControllers.first else {
            return
        }

        segmentedControl.selectedSegmentIndex = 0

        guard isCurrentlyVisible else {
            return setVisibleViewController(firstViewController)
        }

        switch transition {
        case .none:
            setVisibleViewController(firstViewController)
        case .slide:
            slideLeftTransition(to: firstViewController)
        }
    }
}
