//
//  OctocatTableHeaderView.swift
//  StretchyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 20/12/2021.
//

import Foundation
import UIKit

class OctocatTableHeaderView: StretchyTableHeaderView {
    
    // UITableView.tableHeaderView needs a defined height: https://developer.apple.com/documentation/uikit/uitableview/1614904-tableheaderview
    static let baseHeight: CGFloat = 250
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "octocats")!)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "This is some bananas"
        return label
    }()
    
    private let titleView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.layer.cornerRadius = 16
        blurVisualEffectView.clipsToBounds = true
        let vibrancyVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.text = "Octocat is the best <3"
        blurVisualEffectView.contentView.addSubview(vibrancyVisualEffectView)
        vibrancyVisualEffectView.contentView.addSubview(label)
        vibrancyVisualEffectView.edgesToSuperview()
        label.edgesToSuperview(insets: .uniform(16))
        return blurVisualEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleView)
        
        imageView.edgesToSuperview()
        
        titleView.leadingToSuperview(offset: 16, usingSafeArea: true)
        titleView.bottomToSuperview(offset: -16, usingSafeArea: true)
    }
}
