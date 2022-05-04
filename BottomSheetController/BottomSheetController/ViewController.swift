//
//  ViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        view = UIView()

        var configuration: UIButton.Configuration = .bordered()
        configuration.title = "Click me!"
        let button = UIButton(configuration: configuration, primaryAction: .init(handler: { _ in
//            let viewController = FittingPageViewController()
            let viewController = FullPageViewController()
//            viewController.tapToDismissEnabled = false
//            viewController.panToDismissEnabled = false
            self.present(viewController, animated: true)
        }))

        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        view.backgroundColor = .black
    }
}
