//
//  AccordionTableViewCell.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 04/08/2022.
//

import UIKit

final class AccordionTableViewCell: UITableViewCell {

    struct Model {
        let title: String
        let details: String
        let expanded: Bool
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()

    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.init(systemName: "chevron.down"), for: .normal)
        return button
    }()

    private let expandableContent: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private lazy var expandableContentHeightConstraint = expandableContent.heightAnchor.constraint(
        equalToConstant: 0
    )

    var model: Model? = nil {
        didSet {
            titleLabel.text = model?.title
            detailsLabel.text = model?.details

            expanded = model?.expanded ?? false

            expandButton.transform = expanded
                ? .init(rotationAngle: .pi - 0.001) // Makes sure button is rotated in the right direction
                : .identity
            expandableContentHeightConstraint.isActive = !expanded
        }
    }

    weak var delegate: ExpandableTableViewCellDelegate?

    private var expanded: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeContent(in: contentView)
        configureContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {
        view.addSubview(titleLabel)
        view.addSubview(expandButton)
        view.addSubview(expandableContent)

        expandableContent.addSubview(detailsLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        expandableContent.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        expandButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        detailsLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        detailsLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let detailsBottomConstraint = detailsLabel.bottomAnchor.constraint(
            lessThanOrEqualTo: expandableContent.bottomAnchor, constant: -4
        )
        detailsBottomConstraint.priority = .fittingSizeLevel // Let detailsLabel "overflow" if necessary (to prevent conflicts)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),

            expandButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            expandButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            expandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            expandableContent.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            expandableContent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            expandableContent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            expandableContent.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -4),
            expandableContentHeightConstraint,

            detailsLabel.topAnchor.constraint(equalTo: expandableContent.topAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: expandableContent.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: expandableContent.trailingAnchor),
            detailsBottomConstraint
        ])
    }

    private func configureContent() {
        selectionStyle = .none

        expandButton.addAction(.init { [weak self] _ in
            guard
                let self = self,
                let tableView = self.superview as? UITableView
            else {
                return
            }

            self.expanded = !self.expanded

            tableView.beginUpdates()

            UIView.animate(
                withDuration: 0.3, // An educated guess about the duration of UITableView's own update animation duration.
                delay: 0,
                options: [
                    .curveEaseInOut,
                    .beginFromCurrentState,
                    .allowAnimatedContent
                ], animations: {
                    self.expandButton.transform = self.expanded
                        ? .init(rotationAngle: .pi - 0.001) // Makes sure button is rotated in the right direction
                        : .identity
                    self.expandableContentHeightConstraint.isActive = !self.expanded
                    self.contentView.layoutIfNeeded()
                }, completion: { completed in
                    self.expanded = completed ? self.expanded : !self.expanded // Revert to previous state if animation was interrupted
                    self.expandButton.transform = self.expanded
                        ? .init(rotationAngle: .pi - 0.001) // Makes sure button is rotated in the right direction
                        : .identity
                    self.expandableContentHeightConstraint.isActive = !self.expanded

                    if completed {
                        self.delegate?.expandableTableViewCell(self, expanded: self.expanded)
                    }
                }
            )

            tableView.endUpdates()
        }, for: .primaryActionTriggered)
    }
}
