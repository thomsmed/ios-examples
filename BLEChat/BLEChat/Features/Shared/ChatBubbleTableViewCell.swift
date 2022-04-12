//
//  ChatBubbleTableViewCell.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import UIKit
import TinyConstraints

struct ChatBubbleMessage {
    let message: String
    let incoming: Bool
}

final class ChatBubbleTableViewCell: UITableViewCell {

    private let wrapperView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var leadingConstraint = wrapperView.leadingToSuperview()
    private lazy var trailingConstraint = wrapperView.trailingToSuperview()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        placeContent(in: contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {

        view.addSubview(wrapperView)

        wrapperView.addSubview(messageLabel)

        messageLabel.edgesToSuperview(insets: .uniform(8))

        wrapperView.topToSuperview(offset: 8)
        wrapperView.bottomToSuperview(offset: -8)
        wrapperView.widthToSuperview(multiplier: 0.85, priority: .defaultHigh)
    }

    func setup(with message: ChatBubbleMessage) {
        messageLabel.text = message.message
        leadingConstraint.isActive = message.incoming
        trailingConstraint.isActive = !message.incoming
        wrapperView.backgroundColor = message.incoming ? .tertiarySystemBackground : .secondarySystemBackground
        wrapperView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            message.incoming ? .layerMaxXMaxYCorner : .layerMinXMaxYCorner
        ]
    }
}
