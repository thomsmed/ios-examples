//
//  OnboardingViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import UIKit

final class OnboardingViewController: UIViewController {

    private lazy var onboardingView = OnboardingView()

    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = onboardingView

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        onboardingView.button.addTarget(self, action: #selector(goNext), for: .primaryActionTriggered)
    }

    @objc private func goNext(_ target: UIButton) {
        viewModel.goNext()
    }
}
