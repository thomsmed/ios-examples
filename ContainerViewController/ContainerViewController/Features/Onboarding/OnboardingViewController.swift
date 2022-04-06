//
//  OnboardingViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

final class OnboardingViewController: UIViewController {

    final class PageViewController: UIViewController {

        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 32, weight: .bold)
            return label
        }()

        let bodyLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 20)
            label.numberOfLines = 0
            return label
        }()

        let button: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Continue", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            return button
        }()

        var index = 0

        override func loadView() {
            view = UIView()

            view.addSubview(titleLabel)
            view.addSubview(bodyLabel)
            view.addSubview(button)

            constrain(titleLabel, bodyLabel, button, view) { title, body, button, container in
                title.top == container.safeAreaLayoutGuide.top + 20
                title.leading == container.safeAreaLayoutGuide.leading + 40

                body.centerY == container.centerY
                body.leading == container.safeAreaLayoutGuide.leading + 40
                body.trailing == container.safeAreaLayoutGuide.trailing - 40

                button.trailing == container.safeAreaLayoutGuide.trailing - 40
                button.bottom == container.safeAreaLayoutGuide.bottom
            }
        }
    }

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil
    )

    private let viewModel: OnboardingViewModel

    private lazy var pages: [PageViewController] = {
        let pageOne = PageViewController()
        pageOne.titleLabel.textColor = .orange
        pageOne.titleLabel.text = "Page one"
        pageOne.bodyLabel.text = "Page one with onboarding info about this app"
        pageOne.button.isHidden = true
        pageOne.index = 0

        let pageTwo = PageViewController()
        pageTwo.titleLabel.textColor = .green
        pageTwo.titleLabel.text = "Page two"
        pageTwo.bodyLabel.text = "Page two with onboarding info about this app"
        pageTwo.button.isHidden = true
        pageTwo.index = 1

        let pageThree = PageViewController()
        pageThree.titleLabel.textColor = .cyan
        pageThree.titleLabel.text = "Page three"
        pageThree.bodyLabel.text = "Page three with onboarding info about this app"
        pageThree.button.addTarget(self, action: #selector(completeOnboarding), for: .primaryActionTriggered)
        pageThree.index = 2

        return [pageOne, pageTwo, pageThree]
    }()

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageViewController.dataSource = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)
    }

    @objc private func completeOnboarding() {
        viewModel.completeOnboarding()
    }
}

extension OnboardingViewController {

    override func loadView() {
        view = UIView()

        addChild(pageViewController)

        view.addSubview(pageViewController.view)

        constrain(pageViewController.view, view) { child, container in
            child.edges == container.edges
        }

        pageViewController.didMove(toParent: self)

        view.backgroundColor = .systemGray2
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let pageViewController = viewController as? PageViewController,
            pageViewController.index > 0
        else { return nil }

        return pages[pageViewController.index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let pageViewController = viewController as? PageViewController,
            pageViewController.index < pages.count - 1
        else { return nil }

        return pages[pageViewController.index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        0
    }
}
