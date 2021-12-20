//
//  TableViewCell.swift
//  BouncyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 13/12/2021.
//

import UIKit
import TinyConstraints

class TableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "This is some bananas"
        label.setHugging(.defaultHigh, for: .vertical)
        label.setCompressionResistance(.defaultHigh, for: .vertical)
        return label
    }()
    
    let bananaImageView: UIImageView = {
        let image = UIImage(named: "Bananas")!
        let imageView = UIImageView(image: image)
        let aspectRatio = imageView.intrinsicContentSize.width / imageView.intrinsicContentSize.height
        imageView.contentMode = .scaleAspectFit
        imageView.widthToHeight(of: imageView, multiplier: aspectRatio)
        return imageView
    }()
    
    private lazy var imageViewLandscapeHeightConstraint = bananaImageView.heightToWidth(of: contentView,
                                                                                        multiplier: 0.25,
                                                                                        relation: .equalOrLess,
                                                                                        isActive: false)
    private lazy var imageViewPortraitHeightConstraint = bananaImageView.heightToWidth(of: contentView,
                                                                                       multiplier: 0.5,
                                                                                       relation: .equalOrLess,
                                                                                       isActive: false)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }

    private func configureUI() {
        backgroundColor = .clear
        
        selectionStyle = .none
        
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(bananaImageView)
        
        titleLabel.topToSuperview(offset: 16)
        titleLabel.leadingToSuperview(offset: 16)
        titleLabel.trailingToSuperview(offset: 16)
        
        bananaImageView.topToBottom(of: titleLabel, offset: 16, relation: .equalOrGreater)
        bananaImageView.bottomToSuperview(offset: -16, relation: .equalOrLess)
        bananaImageView.centerXToSuperview()
        
        traitCollectionChanged(from: nil)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitHeightConstraint.isActive = false
            imageViewLandscapeHeightConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeHeightConstraint.isActive = false
            imageViewPortraitHeightConstraint.isActive = true
        }
    }
}
