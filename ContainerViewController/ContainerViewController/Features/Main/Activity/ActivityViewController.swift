//
//  ActivityViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

final class ActivityViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .green
        label.text = "Activity"
        return label
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Activity"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActivityViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)

        constrain(label, view) { label, container in
            label.center == container.safeAreaLayoutGuide.center
        }

        view.backgroundColor = .systemGray6
    }
}
