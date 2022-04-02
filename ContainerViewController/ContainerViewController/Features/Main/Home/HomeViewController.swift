//
//  HomeViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

class HomeViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .orange
        label.text = "Home"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
    }
}

extension HomeViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)

        constrain(label, view) { label, container in
            label.center == container.center
        }

        view.backgroundColor = .black
    }
}
