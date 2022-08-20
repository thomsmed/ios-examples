//
//  TableViewController.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class TableViewController: UITableViewController {

    struct Model {
        let name: String = "Luke Skywalker"
        let imageName: String = "luke"
        let facts: [(label: String, text: String)] = [
            (label: "Homeworld", text: "Tatooine"),
            (label: "Species", text: "Human"),
            (label: "Gender", text: "Male"),
            (label: "Height", text: "172 cm"),
            (label: "Weight", text: "77 kg"),
            (label: "Hair color", text: "Blond"),
            (label: "Skin color", text: "Fair"),
            (label: "Birth year", text: "19BBY")
        ]
        let films: [(title: String, imageName: String)] = [
            (title: "A New Hope", imageName: "episode4"),
            (title: "The Empire Strikes Back", imageName: "episode5"),
            (title: "Return of the Jedi", imageName: "episode6"),
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

        headerView.model = .init(name: model.name, imageName: model.imageName)
        headerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(toggleExpandedHeaderView)
            )
        )

        footerView.models = model.films.map { film in
            .init(
                title: film.title,
                imageName: film.imageName
            )
        }
        footerView.expandButton.addTarget(
            self,
            action: #selector(toggleExpandedFooterView),
            for: .primaryActionTriggered
        )

        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.layoutIfNeeded() // To make sure TableHeader- and TableFooterView's layout are updated.
    }

    @objc private func toggleExpandedHeaderView() {
        tableView.beginUpdates()

        // 0.3 is an educated guess about the duration of UITableView's own update animation duration.
        UIView.animate(withDuration: 0.3) {
            self.headerView.expanded = !self.headerView.expanded
            self.tableView.layoutIfNeeded()
        }

        tableView.endUpdates()
    }

    @objc private func toggleExpandedFooterView() {
        tableView.beginUpdates()

        // 0.3 is an educated guess about the duration of UITableView's own update animation duration.
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.footerView.expanded = !self.footerView.expanded
                self.tableView.layoutIfNeeded()
            }
        ) { _ in
            self.tableView.scrollRectToVisible(self.footerView.frame, animated: true)
        }

        tableView.endUpdates()
    }
}

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.facts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    
        let fact = model.facts[indexPath.row]

        var configuration = cell.defaultContentConfiguration()
        configuration.text = fact.text
        configuration.secondaryText = fact.label

        cell.selectionStyle = .none
        cell.contentConfiguration = configuration

        return cell
    }
}
