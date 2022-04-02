//
//  ProfileViewController.swift
//  ContainerViewController
//
//  Created by Thomas Asheim Smedmann on 02/04/2022.
//

import UIKit
import Cartography

final class ProfileViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .blue
        label.text = "Your profile"
        return label
    }()

    let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(signOut))
    }

    @objc private func signOut(_ target: UIBarButtonItem) {
        viewModel.signOut()
    }
}

extension ProfileViewController {

    override func loadView() {
        view = UIView()

        view.addSubview(label)

        constrain(label, view) { label, container in
            label.center == container.center
        }

        view.backgroundColor = .black
    }
}
