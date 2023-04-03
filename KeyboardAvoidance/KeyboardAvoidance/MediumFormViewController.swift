//
//  MediumFormViewController.swift
//  KeyboardAvoidance
//
//  Created by Thomas Asheim Smedmann on 03/04/2023.
//

import UIKit

final class MediumFormViewController: KeyboardAvoidanceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let verticalStackView = UIStackView(arrangedSubviews: [
            FormView(
                textViewOneText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus.",
                textViewTwoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus. Etiam congue bibendum venenatis. Vivamus eros sapien, finibus at lacinia eu, vestibulum eu urna.",
                offsetLayoutPriority: 0
            ),
            FormView(
                textViewOneText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus.",
                textViewTwoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus. Etiam congue bibendum venenatis. Vivamus eros sapien, finibus at lacinia eu, vestibulum eu urna.",
                offsetLayoutPriority: 1
            ),
            FormView(
                textViewOneText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus.",
                textViewTwoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus. Etiam congue bibendum venenatis. Vivamus eros sapien, finibus at lacinia eu, vestibulum eu urna.",
                offsetLayoutPriority: 2
            )
        ])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 16

        pinToContentView(verticalStackView)
    }
}
