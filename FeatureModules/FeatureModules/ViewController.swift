//
//  ViewController.swift
//  FeatureModules
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit

final class ViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .regular)
        return label
    }()

    override func loadView() {
        let view = UIView()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.backgroundColor = .systemBackground

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "Hello World!"
    }
}
