//
//  StoreListViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 07/07/2022.
//

import UIKit
import Combine

protocol StoreListViewHolder: UIViewController {
    
}

final class StoreListViewController: UIViewController {

    private lazy var storeListView = StoreListView()

    private let viewModel: StoreListViewModel

    private var stateSub: AnyCancellable?

    init(viewModel: StoreListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = storeListView

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        storeListView.filterOptionsButton.addTarget(
            self,
            action: #selector(selectFilterOptions),
            for: .primaryActionTriggered
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        stateSub = viewModel.state.sink { [weak self] state in
            switch state {
            case .idle:
                return
            case .loading:
                self?.storeListView.statusLabel.text = "Loading..."
            case .ready:
                self?.storeListView.statusLabel.text = "Ready!"
            case .error:
                self?.storeListView.statusLabel.text = "Error..."
            }
        }
    }

    @objc private func selectFilterOptions(_ target: UIButton) {
        viewModel.selectStoreFilterOptions()
    }
}

extension StoreListViewController: StoreListViewHolder {
    
}
