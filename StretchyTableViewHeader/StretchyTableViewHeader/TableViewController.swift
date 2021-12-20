//
//  TableViewController.swift
//  StretchyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 19/12/2021.
//

import UIKit

typealias Octocat = (name: String, imagePath: String)

extension String {
    func capitalizeFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizeFirstLetter()
    }
}

class TableViewController: UITableViewController {
    
    // Octocats downloaded from https://octodex.github.com/, and bundled together with the app as raw resources
    private let octocats: [Octocat] = Bundle.main.paths(forResourcesOfType: nil,
                                                        inDirectory: "octocats").map { imagePath in
        let name = String(imagePath.split(separator: "/").last?.split(separator: ".").first ?? "")
            .capitalizeFirstLetter()
        return Octocat(name: name, imagePath: imagePath)
    }
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private let tableHeaderView: StretchyTableHeaderView = OctocatTableHeaderView(frame: CGRect(origin: .zero,
                                                                                                size: CGSize(width: .zero,
                                                                                                             height: OctocatTableHeaderView.baseHeight)))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.tableHeaderView = tableHeaderView
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        octocats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell
        else {
            return UITableViewCell()
        }
        let tag = indexPath.row + 1 // Default value for UIView.tag is 0
        let octocat = octocats[indexPath.row]
        cell.setup(with: octocat, and: tag)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = indexPath.row + 1
        let octocat = octocats[indexPath.row]
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
        let fullScreenImageViewController = FullScreenImageViewController(octocat: octocat, tag: tag)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
}

// MARK: UIScrollViewDelegate

extension TableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableHeaderView.scrollViewDidScroll(scrollView)
    }
}
