//
//  TableFooterView.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class FilmCollectionViewCell: UICollectionViewCell {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {
        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

final class TableFooterView: UIView {

    private static let collectionViewHeight: CGFloat = 200

    struct Model {
        let title: String
        let imageName: String
    }

    private let textLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(.init(systemName: "chevron.down"), for: .normal)
        return button
    }()

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(collectionViewHeight / 2),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(.greatestFiniteMagnitude),
                    heightDimension: .fractionalHeight(1.0)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
                section.interGroupSpacing = 0

                let configuration = UICollectionViewCompositionalLayoutConfiguration()
                configuration.scrollDirection = .horizontal

                let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
                return layout
            }()
        )
        return collectionView
    }()

    private lazy var collapsedConstraints: [NSLayoutConstraint] = {
        let expandButtonTrailingConstraint = expandButton.trailingAnchor.constraint(
            equalTo: trailingAnchor, constant: -16
        )
        expandButtonTrailingConstraint.priority = .required - 1
        let textLabelBottomConstraint = textLabel.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -8
        )
        textLabelBottomConstraint.priority = .required - 1

        return [
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabelBottomConstraint,

            expandButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            expandButton.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8),
            expandButtonTrailingConstraint,

            collectionView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Self.collectionViewHeight)
        ]
    }()

    private lazy var expandedConstraints: [NSLayoutConstraint] = {
        let expandButtonTrailingConstraint = expandButton.trailingAnchor.constraint(
            equalTo: trailingAnchor, constant: -16
        )
        expandButtonTrailingConstraint.priority = .required - 1
        let collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -8
        )
        collectionViewBottomConstraint.priority = .required - 1

        return [
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            expandButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            expandButton.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8),
            expandButtonTrailingConstraint,

            collectionView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Self.collectionViewHeight),
            collectionViewBottomConstraint
        ]
    }()

    var models: [Model] = [] {
        didSet {
            textLabel.text = "Appears in \(models.count) Star Wars films"
            collectionView.reloadSections(.init(integer: 0))
        }
    }

    var expanded: Bool = false {
        didSet {
            if expanded {
                expandButton.transform = .init(rotationAngle: .pi - 0.001) // Makes sure button is rotated in the right direction
                NSLayoutConstraint.deactivate(collapsedConstraints)
                NSLayoutConstraint.activate(expandedConstraints)
            } else {
                expandButton.transform = .identity
                NSLayoutConstraint.deactivate(expandedConstraints)
                NSLayoutConstraint.activate(collapsedConstraints)
            }
        }
    }

    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, Int>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: self)

        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FilmCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        clipsToBounds = true // Makes sure the collection view don't overflow when collapsed
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
        view.addSubview(textLabel)
        view.addSubview(expandButton)
        view.addSubview(collectionView)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(collapsedConstraints)
    }
}

extension TableFooterView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilmCollectionViewCell

        let model = models[indexPath.row]

        cell.imageView.image = UIImage(named: model.imageName)

        return cell
    }
}
