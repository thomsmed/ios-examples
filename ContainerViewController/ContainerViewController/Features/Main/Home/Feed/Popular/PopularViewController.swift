//
//  PopularViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 03/04/2022.
//

import UIKit
import Cartography

final class PopularViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .orange
        label.text = "Popular"
        return label
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Popular"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PopularViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)

        constrain(label, view) { label, container in
            label.center == container.safeAreaLayoutGuide.center
        }
    }
}
