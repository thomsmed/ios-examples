//
//  CheckoutViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 08/07/2022.
//

import UIKit

protocol CheckoutViewHolder: UIViewController {

}

final class CheckoutViewController: UIViewController {

    private let viewModel: CheckoutViewModel

    init(viewModel: CheckoutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckoutViewController: CheckoutViewHolder {
    
}
