//
//  AccordionTableViewController.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 04/08/2022.
//

import UIKit

final class AccordionTableViewController: UITableViewController {

    private var items: [AccordionTableViewCell.Model] = (1..<100).map { number in
        .init(
            title: "Item \(number)" ,
            details: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vitae libero at purus efficitur lacinia. Nulla ullamcorper rhoncus velit, vel efficitur arcu porttitor in. Aenean dictum eros ut augue ornare efficitur.
            """,
            expanded: false
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Accordion"

        tableView.separatorInset = .zero
        tableView.register(AccordionTableViewCell.self, forCellReuseIdentifier: "cell")

        let headerView = HeaderView()
        headerView.frame.size = headerView.systemLayoutSizeFitting(
            .init(
                width: tableView.frameLayoutGuide.layoutFrame.width,
                height: 0
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        tableView.tableHeaderView = headerView
    }
}

extension AccordionTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AccordionTableViewCell

        cell.delegate = self
        cell.model = items[indexPath.row]

        return cell
    }
}

extension AccordionTableViewController: ExpandableTableViewCellDelegate {

    func expandableTableViewCell(_ tableViewCell: UITableViewCell, expanded: Bool) {
        // Somehow take note of which cells that are currently expanded.

        guard let indexPath = tableView.indexPath(for: tableViewCell) else {
            return
        }

        let item = items[indexPath.row]

        items[indexPath.row] = .init(
            title: item.title,
            details: item.details,
            expanded: expanded
        )
    }
}
