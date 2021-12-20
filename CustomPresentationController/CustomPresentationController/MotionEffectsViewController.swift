//
//  MotionEffectsViewController.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 09/11/2021.
//

import UIKit

class MotionEffectsViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            topLabel,
            middleLabel,
            bottomLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.text = "I move with motion"
        label.textColor = .systemBlue
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        horizontalMotionEffect.minimumRelativeValue = 100
        horizontalMotionEffect.maximumRelativeValue = -100
        verticalMotionEffect.minimumRelativeValue = 100
        verticalMotionEffect.maximumRelativeValue = -100
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        label.addMotionEffect(motionEffectGroup)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let middleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.text = "My shadow move with motion"
        label.textColor = .label
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 10
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = .zero
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.width", type: .tiltAlongHorizontalAxis)
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.height", type: .tiltAlongVerticalAxis)
        horizontalMotionEffect.minimumRelativeValue = 100
        horizontalMotionEffect.maximumRelativeValue = -100
        verticalMotionEffect.minimumRelativeValue = 100
        verticalMotionEffect.maximumRelativeValue = -100
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        label.addMotionEffect(motionEffectGroup)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.text = "I move with motion"
        label.textColor = .systemRed
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        horizontalMotionEffect.minimumRelativeValue = 100
        horizontalMotionEffect.maximumRelativeValue = -100
        verticalMotionEffect.minimumRelativeValue = 100
        verticalMotionEffect.maximumRelativeValue = -100
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        label.addMotionEffect(motionEffectGroup)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
