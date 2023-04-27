//
//  TableContentSheetViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 05/04/2023.
//

import UIKit

final class TableContentSheetViewController: BottomSheetController {

    private let thingsNavigationController: UINavigationController = {
        let navigationController = UINavigationController(
            rootViewController: ThingsViewController(style: .insetGrouped)
        )
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        return navigationController
    }()

    override func loadView() {
        view = UIView()

        addChild(thingsNavigationController)

        view.addSubview(thingsNavigationController.view)

        NSLayoutConstraint.activate([
            thingsNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            thingsNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thingsNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thingsNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        thingsNavigationController.didMove(toParent: self)
    }
}

final class ThingsViewController: UITableViewController {

    final class ThingViewController: UIViewController {

        let textLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 24)
            return label
        }()

        override func loadView() {
            view = UIView()

            view.addSubview(textLabel)

            NSLayoutConstraint.activate([
                textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

            view.backgroundColor = .systemBackground
        }
    }

    private let things: [String] = (1..<10).map { "Thing \($0)" }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "A list of things"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        things.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var configuration = cell.defaultContentConfiguration()
        configuration.text = things[indexPath.row]

        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let thingViewController = ThingViewController()

        thingViewController.title = things[indexPath.row]
        thingViewController.textLabel.text = "This is thing \(indexPath.row + 1)"

        navigationController?.pushViewController(thingViewController, animated: true)
    }
}
