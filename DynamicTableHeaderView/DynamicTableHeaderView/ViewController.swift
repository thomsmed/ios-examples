//
//  ViewController.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class ViewController: UITableViewController {

    struct Model {
        let name: String = "Luke Skywalker"
        let imageName: String = "luke"
        let homeworld: String = "Tatooine"
        let species: String = "Human"
        let gender: String = "Male"
        let height: String = "172 cm"
        let weight: String = "77 kg"
        let hairColor: String = "Blond"
        let skinColor: String = "Fair"
        let birthYear: String = "19BBY"
        let films: [(title: String, imageName: String)] = [
            (title: "A New Hope", imageName: "episode3"),
            (title: "The Empire Strikes Back", imageName: "episode4"),
            (title: "Return of the Jedi", imageName: "episode5"),
            (title: "Revenge of the Sith", imageName: "episode3"),
            (title: "The Force Awakens", imageName: "episode7"),
            (title: "The Last Jedi", imageName: "episode8"),
            (title: "The Rise of Skywalker", imageName: "episode9"),
        ]
    }

    private let headerView = TableHeaderView()
    private let footerView = TableFooterView()

    private let model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView

        headerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(toggleExpandedHeaderView)
            )
        )
        headerView.model = .init(name: model.name, imageName: model.imageName)
    }

    @objc private func toggleExpandedHeaderView() {
        if headerView.expanded {
            headerView.collapse()
        } else {
            headerView.expand()
        }
    }
}
