//
//  ViewController.swift
//  BouncyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 13/12/2021.
//

import UIKit
import TinyConstraints

class ViewController: UITableViewController {
    private let tableViewHeaderView = TableViewHeaderView(frame: .zero)
    
    private let tableViewBackgroundView: UIView = {
        let imageView = UIImageView(image: UIImage(named: "MoreBananas")!)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.backgroundView = tableViewBackgroundView
        tableView.tableHeaderView = tableViewHeaderView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        traitCollectionChanged(from: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Landscape
            tableViewHeaderView.frame.size = CGSize(width: 0, height: TableViewHeaderView.basisHeight / 2)
        } else {
            // Portrait
            tableViewHeaderView.frame.size = CGSize(width: 0, height: TableViewHeaderView.basisHeight / 2)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell else { return UITableViewCell() }
        cell.bananaImageView.tag = indexPath.row + 1 // 0 is default value for all views
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else { return }
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorView: cell.bananaImageView)
        let viewController = FullScreenImageViewController(tag: cell.bananaImageView.tag)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = fullScreenTransitionManager
        present(viewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
}

extension ViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewHeaderView.scrollViewDidScroll(scrollView)
    }
}
