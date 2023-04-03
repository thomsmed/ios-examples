//
//  ShortFormViewController.swift
//  KeyboardAvoidance
//
//  Created by Thomas Asheim Smedmann on 03/04/2023.
//

import UIKit

final class ShortFormViewController: KeyboardAvoidanceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        pinToContentView(
            FormView(
                textViewOneText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus.",
                textViewTwoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at est lobortis, mollis metus ut, eleifend lectus. Etiam congue bibendum venenatis. Vivamus eros sapien, finibus at lacinia eu, vestibulum eu urna.",
                offsetLayoutPriority: 0
            )
        )
    }
}

