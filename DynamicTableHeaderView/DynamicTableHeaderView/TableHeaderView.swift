//
//  TableHeaderView.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class TableHeaderView: UIView {

    struct Model {
        let name: String
        let imageName: String
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var collapsedConstraints: [NSLayoutConstraint] = {
        let nameLabelBottomConstraint = nameLabel.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -16
        )
        nameLabelBottomConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations
        return [
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabelBottomConstraint
        ]
    }()

    private lazy var expandedConstraints: [NSLayoutConstraint] = {
        let imageViewTrailingConstraint = imageView.trailingAnchor.constraint(
            equalTo: trailingAnchor
        )
        imageViewTrailingConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations
        let nameLabelTrailingConstraint = nameLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: trailingAnchor, constant: -16
        )
        nameLabelTrailingConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        return [
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageViewTrailingConstraint,
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabelTrailingConstraint,
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
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
                NSLayoutConstraint.deactivate(collapsedConstraints)
                NSLayoutConstraint.activate(expandedConstraints)
            } else {
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

        // TODO: Explain this essential trick
        frame.size = systemLayoutSizeFitting(
            .init(width: frame.size.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    private func placeContent(in view: UIView) {
        view.addSubview(imageView)
        view.addSubview(nameLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(collapsedConstraints)
    }
}
