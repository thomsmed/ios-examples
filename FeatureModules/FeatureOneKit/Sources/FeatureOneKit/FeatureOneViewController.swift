//
//  FeatureOneViewController.swift
//  
//
//  Created by Thomas Asheim Smedmann on 20/11/2022.
//

import UIKit

final class FeatureOneViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .regular)
        return label
    }()

    private weak var coordinator: FeatureOneCoordinator?

    init(coordinator: FeatureOneCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.backgroundColor = .white

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "This is feature one!"
    }
}
