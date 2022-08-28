//
//  EmojiCollectionViewCell.swift
//  LiveMockData
//
//  Created by Thomas Asheim Smedmann on 28/08/2022.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .regular)
        return label
    }()

    var emoji: String? = nil {
        didSet {
            emojiLabel.text = emoji
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {
        view.addSubview(emojiLabel)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
}
