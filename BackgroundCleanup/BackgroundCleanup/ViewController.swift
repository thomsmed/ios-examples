//
//  ViewController.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 15/07/2022.
//

import UIKit

class ViewController: UIViewController {

    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Hello there!"
        return label
    }()

    override func loadView() {
        view = UIView()

        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

