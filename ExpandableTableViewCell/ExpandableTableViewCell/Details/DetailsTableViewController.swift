//
//  DetailsTableViewController.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 05/08/2022.
//

import UIKit

final class DetailsTableViewController: UITableViewController {

    private var persons: [DetailsTableViewCell.Model] = (1..<100).map { number in
        return .init(
            image: .init(systemName: "person")!,
            name: "Person \(number)",
            details: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vitae libero at purus efficitur lacinia. Nulla ullamcorper rhoncus velit, vel efficitur arcu porttitor in. Aenean dictum eros ut augue ornare efficitur.
            """
        )
    }

    private var expandedCells: [IndexPath: Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Expandable details"

        tableView.separatorInset = .zero
        tableView.register(DetailsTableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension DetailsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        persons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailsTableViewCell

        let person = persons[indexPath.row]

        cell.model = person
        cell.expanded = expandedCells[indexPath] ?? false

        return cell
    }
}

extension DetailsTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Somehow take note of which cells that are currently expanded,
        // and optionally animate the expanding / collapsing cell.

        guard let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell else {
            return
        }

        let expand = !(expandedCells[indexPath] ?? false)

        tableView.beginUpdates()

        // 0.3 is an educated guess about the duration of UITableView's own update animation duration.
        UIView.animate(withDuration: 0.3) {
            cell.expanded = expand
        }

        tableView.endUpdates()

        expandedCells[indexPath] = expand
    }
}
