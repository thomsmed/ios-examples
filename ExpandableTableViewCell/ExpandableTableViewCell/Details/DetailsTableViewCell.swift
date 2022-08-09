//
//  DetailsTableViewCell.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 05/08/2022.
//

import UIKit

final class DetailsTableViewCell: UITableViewCell {

    struct Model {
        let image: UIImage
        let name: String
        let details: String
    }

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private var constraintsForCollapsedContent: [NSLayoutConstraint] = []
    private var constraintsForExpandedContent: [NSLayoutConstraint] = []

    weak var delegate: ExpandableTableViewCellDelegate?

    var model: Model? = nil {
        didSet {
            profileImageView.image = model?.image
            nameLabel.text = model?.name
            detailsLabel.text = model?.details
        }
    }

    var expanded = false {
        didSet {
            if expanded {
                NSLayoutConstraint.deactivate(constraintsForCollapsedContent)
                NSLayoutConstraint.activate(constraintsForExpandedContent)
            } else {
                NSLayoutConstraint.deactivate(constraintsForExpandedContent)
                NSLayoutConstraint.activate(constraintsForCollapsedContent)
            }

            detailsLabel.alpha = expanded ? 1 : 0

            contentView.layoutIfNeeded()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeContent(in: contentView)
        configureContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func constraintsForCollapsedContent(in view: UIView) -> [NSLayoutConstraint] {
        let profileImageBottomConstraint = profileImageView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -8
        )
        profileImageBottomConstraint.priority = .defaultHigh

        return [
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            profileImageBottomConstraint,
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),

            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100 + 2 * 8),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ]
    }

    private func constraintsForExpandedContent(in view: UIView) -> [NSLayoutConstraint] {
        let profileImageBottomConstraint = profileImageView.bottomAnchor.constraint(
            lessThanOrEqualTo: contentView.bottomAnchor, constant: -8
        )
        profileImageBottomConstraint.priority = .defaultHigh

        let detailsBottomConstraint = detailsLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor, constant: -8
        )
        detailsBottomConstraint.priority = .defaultHigh

        return [
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            profileImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            profileImageBottomConstraint,
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100 + 2 * 8),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            detailsBottomConstraint
        ]
    }

    private func placeContent(in view: UIView) {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(detailsLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        constraintsForCollapsedContent = constraintsForCollapsedContent(in: view)
        constraintsForExpandedContent = constraintsForExpandedContent(in: view)

        NSLayoutConstraint.activate(constraintsForCollapsedContent)

        detailsLabel.alpha = 0
    }

    private func configureContent() {
        selectionStyle = .none
        contentView.clipsToBounds = true
    }
}
