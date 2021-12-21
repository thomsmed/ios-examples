//
//  TableViewCell.swift
//  StretchyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 19/12/2021.
//

import UIKit
import TinyConstraints

class TableViewCell: UITableViewCell {
    private let octocatNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.setHugging(.defaultHigh, for: .vertical)
        label.setCompressionResistance(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let octocatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private lazy var imageViewWidthConstraint = octocatImageView.width(.zero)
    
    private let imageHeight: CGFloat = 200

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        selectionStyle = .none
        
        contentView.addSubview(octocatNameLabel)
        contentView.addSubview(octocatImageView)
        
        octocatNameLabel.topToSuperview(offset: 16)
        octocatNameLabel.leadingToSuperview(offset: 16)
        octocatNameLabel.trailingToSuperview(offset: 16)
        
        octocatImageView.topToBottom(of: octocatNameLabel, offset: 16)
        octocatImageView.height(imageHeight)
        octocatImageView.centerXToSuperview()
        octocatImageView.bottomToSuperview(offset: -16)
    }
    
    func setup(with octocat: Octocat, and tag: Int) {
        octocatNameLabel.text = octocat.name
        octocatImageView.image = UIImage(contentsOfFile: octocat.imagePath)
        octocatImageView.tag = tag
        
        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = octocatImageView.intrinsicContentSize.width / octocatImageView.intrinsicContentSize.height
        imageViewWidthConstraint.constant = imageHeight * aspectRatio
    }
}
