//
//  HeaderView.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 08/08/2022.
//

import UIKit

final class HeaderView: UIView {

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Toggle", for: .normal)
        return button
    }()

    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(equalToConstant: 50)
        constraint.priority = .required - 1 // To avoid temporary conflicts during resizing.
        return constraint
    }()

    var expanded: Bool = false {
        didSet {
            if expanded {
                heightConstraint.constant = 100
            } else {
                heightConstraint.constant = 50
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: self)
        configureBehaviour()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightConstraint
        ])
    }

    private func configureBehaviour() {
        button.addAction(.init { [weak self] _ in
            guard let self = self else { return }

            guard let tableView = self.superview as? UITableView else { return }

            tableView.beginUpdates()

            // 0.3 is an educated guess about the duration of UITableView's own update animation duration.
            UIView.animate(withDuration: 0.3) {
                self.expanded = !self.expanded

                self.frame.size = self.systemLayoutSizeFitting(
                    .init(
                        width: tableView.frameLayoutGuide.layoutFrame.width,
                        height: 0
                    ),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )

                self.layoutIfNeeded()
            }

            tableView.endUpdates()
        }, for: .primaryActionTriggered)
    }
}
