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

        let button1 = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FittingPageViewController()
            viewController.preferredSheetSizing = .fit
            self.present(viewController, animated: true)
        }))
        button1.setTitle("Fitting - fit", for: .normal)

        let button2 = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FittingPageViewController()
            viewController.preferredSheetSizing = .small
            self.present(viewController, animated: true)
        }))
        button2.setTitle("Fitting - small", for: .normal)

        let button3 = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FittingPageViewController()
            viewController.preferredSheetSizing = .medium
            self.present(viewController, animated: true)
        }))
        button3.setTitle("Fitting - medium", for: .normal)

        let button4 = UIButton(type: .system, primaryAction: .init(handler: { _ in
            let viewController = FittingPageViewController()
            viewController.preferredSheetSizing = .large
            self.present(viewController, animated: true)
        }))
        button4.setTitle("Fitting - large", for: .normal)

        let stackView = UIStackView(arrangedSubviews: [
            button1,
            button2,
            button3,
            button4
        ])
        stackView.axis = .vertical
        stackView.spacing = 20

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        view.backgroundColor = .black
    }
}
