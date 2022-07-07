//
//  StoreViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 08/07/2022.
//

import UIKit

final class StoreViewController: UIViewController {

    private let viewModel: StoreViewModel

    init(viewModel: StoreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
