//
//  TableHeaderView.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class TableHeaderView: UIView {

    private static let defaultImageSize: CGFloat = 100

    struct Model {
        let name: String
        let imageName: String
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var collapsedConstraints: [NSLayoutConstraint] = {
        let imageViewHeightConstraint = imageView.heightAnchor.constraint(
            equalToConstant: Self.defaultImageSize
        )
        imageViewHeightConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations
        let nameLabelBottomConstraint = nameLabel.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16
        )
        nameLabelBottomConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        return [
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageViewHeightConstraint,
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabelBottomConstraint
        ]
    }()

    private lazy var expandedConstraints: [NSLayoutConstraint] = {
        let imageViewHeightConstraint = imageView.heightAnchor.constraint(
            equalToConstant: Self.defaultImageSize * 3
        )
        imageViewHeightConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        return [
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            imageViewHeightConstraint,
            imageView.heightAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: imageView.trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ]
    }()

    var model: Model? = nil {
        didSet {
            nameLabel.text = model?.name
            imageView.image = UIImage(named: model?.imageName ?? "")
        }
    }

    var expanded: Bool = false {
        didSet {
            if expanded {
                imageView.layer.cornerRadius = Self.defaultImageSize / 8
                NSLayoutConstraint.deactivate(collapsedConstraints)
                NSLayoutConstraint.activate(expandedConstraints)
            } else {
                imageView.layer.cornerRadius = Self.defaultImageSize / 2
                NSLayoutConstraint.deactivate(expandedConstraints)
                NSLayoutConstraint.activate(collapsedConstraints)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Manually set the view's frame based on layout constraints.
        // The parent UITableView uses the header view's frame height when laying out it's subviews.
        // Only the header view's height is respected.
        // The UITableView ignores the view frame's width.
        // Documentation: https://developer.apple.com/documentation/uikit/uitableview/1614904-tableheaderview
        frame.size = systemLayoutSizeFitting(
            .init(
                width: frame.size.width,
                height: 0
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    private func placeContent(in view: UIView) {
        view.addSubview(imageView)
        view.addSubview(nameLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        imageView.layer.cornerRadius = Self.defaultImageSize / 2

        NSLayoutConstraint.activate(collapsedConstraints)
    }
}
