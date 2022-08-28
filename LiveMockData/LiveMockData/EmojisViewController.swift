//
//  EmojisViewController.swift
//  LiveMockData
//
//  Created by Thomas Asheim Smedmann on 28/08/2022.
//

import UIKit
import Combine

final class EmojisViewController: UIViewController {

    private lazy var collectionViewLayout = UICollectionViewCompositionalLayout(
        sectionProvider: { sectionIndex, layoutEnvironment in
            let effectiveContentSize = layoutEnvironment.container.effectiveContentSize
            let isHorizontal = effectiveContentSize.width > effectiveContentSize.height

            if isHorizontal {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalHeight(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.25)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)
            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.25),
                    heightDimension: .fractionalWidth(0.25)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(0.25)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)
            }
        }
    )

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<Int, Emoji>(
        collectionView: collectionView,
        cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell", for: indexPath
            ) as? EmojiCollectionViewCell else {
                return nil
            }

            cell.emoji = self.emojis[indexPath.row]

            return cell
        }
    )

    private let emojiRepository: EmojiRepository = MockEmojiRepository()

    private var emojis: [Emoji] = []

    private var subscription: AnyCancellable?

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let configuration = collectionViewLayout.configuration
        configuration.scrollDirection = traitCollection.verticalSizeClass == .compact ? .horizontal : .vertical
        collectionViewLayout.configuration = configuration
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        subscription = emojiRepository.emojis.sink { [weak self] emojis in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Emoji>()
            snapshot.appendSections([0])
            snapshot.appendItems(emojis)

            self?.emojis = emojis

            self?.collectionViewDataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        subscription?.cancel()
    }
}
