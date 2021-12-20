//
//  StretchyTableHeaderView.swift
//  StretchyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 20/12/2021.
//

import Foundation
import UIKit
import TinyConstraints

class StretchyTableHeaderView: UIView {
    internal let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var contentViewTopConstraint = contentView.topToSuperview()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(contentView)
        
        contentView.leadingToSuperview()
        contentView.trailingToSuperview()
        contentView.bottomToSuperview()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = min(scrollView.contentOffset.y, 0)
        if offset > -scrollView.safeAreaInsets.top {
            offset = -scrollView.safeAreaInsets.top
        }
        contentViewTopConstraint.constant = offset
    }
}
