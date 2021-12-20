//
//  CircleView.swift
//  CustomInterfaceBuilderView
//
//  Created by Thomas Asheim Smedmann on 10/09/2021.
//

import UIKit

@IBDesignable
class CircularView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = CGFloat(min(bounds.width / 2, bounds.height / 2))
        layer.masksToBounds = true
    }
}
