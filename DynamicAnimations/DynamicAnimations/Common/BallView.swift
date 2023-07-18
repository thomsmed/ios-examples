//
//  BallView.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 17/07/2023.
//

import UIKit

final class BallView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    var gradientColors: [UIColor] = [] {
        didSet {
            let gradientLayer = layer as! CAGradientLayer

            gradientLayer.colors = gradientColors.map { $0.cgColor }
        }
    }

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradientLayer = layer as! CAGradientLayer

        gradientLayer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    private func configure() {
        clipsToBounds = true

        let gradientLayer = layer as! CAGradientLayer

        gradientLayer.type = .radial
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
}
