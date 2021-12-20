//
//  VisualEffectsViewController.swift
//  CustomPresentationController
//
//  Created by Thomas Asheim Smedmann on 09/11/2021.
//

import UIKit

class VisualEffectsViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "fruit")!)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            systemThinMaterialBlurEffectView,
            systemMaterialBlurEffectView,
            systemThickMaterialBlurEffectView,
            systemChromeMaterialBlurEffectView
        ])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let systemThinMaterialBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = ".systemThinMaterial"
        label.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        visualEffectView.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
        ])
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private let systemMaterialBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = ".systemMaterial"
        label.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        visualEffectView.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
        ])
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private let systemThickMaterialBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = ".systemThickMaterial"
        label.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        visualEffectView.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
        ])
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private let systemChromeMaterialBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = ".systemChromeMaterial"
        label.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        visualEffectView.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor)
        ])
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
}
