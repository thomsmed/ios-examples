//
//  RootViewController.swift
//  ExtendedSplashScreen
//
//  Created by Thomas Asheim Smedmann on 19/04/2023.
//

import UIKit

/// This class effectively act as a custom container ViewController,
/// governing the top of the View/ViewController hierarchy in the app.
///
/// For the basic idea about Custom Container View Controllers,
/// take a look at [Custom Container View Controller](https://medium.com/@thomsmed/custom-container-view-controller-89123e3f2df9).
final class RootViewController: UIViewController {
    private let deviceManager = DeviceManager()

    private func setViewController(_ viewController: UIViewController) {
        guard let previousViewController = children.first else {
            addChild(viewController)

            view.addSubview(viewController.view)

            viewController.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            return viewController.didMove(toParent: self)
        }

        previousViewController.willMove(toParent: nil)

        addChild(viewController)

        UIView.transition(
            from: previousViewController.view,
            to: viewController.view,
            duration: 0.25
        ) { _ in
            viewController.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

            previousViewController.removeFromParent()

            viewController.didMove(toParent: self)
        }
    }

    override func loadView() {
        view = UIView()

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show a splash screen while we do some initial app/device checks.
        setViewController(SplashScreenViewController())

        // Run some initial app/device check.
        runDeviceCheck()
    }
}

extension RootViewController {
    func runDeviceCheck() {
        Task {
            let result = await deviceManager.checkDevice()

            switch result {
                case .blocked:
                    setViewController(AppBlockedViewController())
                case .ok:
                    setViewController(MainViewController())
            }
        }
    }
}
