//
//  TableViewHeaderView.swift
//  BouncyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 14/12/2021.
//

import UIKit
import TinyConstraints

class TableViewHeaderView: UIView {
    static let basisHeight: CGFloat = 300
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    let bananaImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Bananas")!)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "This is some bananas"
        return label
    }()
    
    private var contentViewTopConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.layer.cornerRadius = 16
        blurVisualEffectView.clipsToBounds = true
        let vibrancyVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        
        addSubview(contentView)
        contentView.addSubview(bananaImageView)
        contentView.addSubview(blurVisualEffectView)
        blurVisualEffectView.contentView.addSubview(vibrancyVisualEffectView)
        vibrancyVisualEffectView.contentView.addSubview(titleLabel)
        
        contentViewTopConstraint = contentView.topToSuperview()
        contentView.leadingToSuperview()
        contentView.trailingToSuperview()
        contentView.bottomToSuperview()
        
        bananaImageView.edgesToSuperview()
        titleLabel.edgesToSuperview(insets: .uniform(16))
        vibrancyVisualEffectView.edgesToSuperview()
        blurVisualEffectView.leadingToSuperview(offset: 16, usingSafeArea: true)
        blurVisualEffectView.bottomToSuperview(offset: -16, usingSafeArea: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = min(scrollView.contentOffset.y, 0)
        if offset > -scrollView.safeAreaInsets.top {
            offset = -scrollView.safeAreaInsets.top
        }
        contentViewTopConstraint?.constant = offset
    }
}
