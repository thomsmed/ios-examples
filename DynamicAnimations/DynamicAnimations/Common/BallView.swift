//
//  BallView.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 17/07/2023.
//

import UIKit

final class BallView: UIView {
    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    private func configure() {
        clipsToBounds = true
    }
}
