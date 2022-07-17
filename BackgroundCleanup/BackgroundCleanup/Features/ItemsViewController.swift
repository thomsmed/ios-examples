//
//  ItemsViewController.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 15/07/2022.
//

import UIKit
import Combine

final class ItemsViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "Items"
        return label
    }()

    let addItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add item", for: .normal)
        return button
    }()

    let itemsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()

    private let viewModel: ItemsViewModel

    private var statusSub: AnyCancellable?

    init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        view.addSubview(titleLabel)
        view.addSubview(addItemButton)
        view.addSubview(itemsTableView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            itemsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            itemsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            itemsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            addItemButton.topAnchor.constraint(equalTo: itemsTableView.bottomAnchor, constant: 16),
            addItemButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])

        itemsTableView.backgroundColor = .secondarySystemBackground

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        itemsTableView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: .init { action in
                self.viewModel.refreshItems()
            }
        )

        itemsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        itemsTableView.dataSource = self

        addItemButton.addAction(.init { action in
            self.viewModel.addItem()
        }, for: .primaryActionTriggered)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        statusSub = viewModel.status.receive(on: DispatchQueue.main).sink { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .idle:
                self.addItemButton.isEnabled = false
                self.viewModel.refreshItems()
            case .loading:
                self.addItemButton.isEnabled = false
                if self.itemsTableView.refreshControl?.isRefreshing == true {
                    return
                }
                self.itemsTableView.refreshControl?.beginRefreshing()
            case .ready:
                self.addItemButton.isEnabled = true
                self.itemsTableView.reloadSections(.init(integer: 0), with: .automatic)
                self.itemsTableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension ItemsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = viewModel.items[indexPath.row]
        cell.textLabel?.text = "\(item.text) (created \(item.timestamp.formatted())"

        return cell
    }
}
