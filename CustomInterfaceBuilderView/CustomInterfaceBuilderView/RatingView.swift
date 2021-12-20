//
//  RatingView.swift
//  CustomInterfaceBuilderView
//
//  Created by Thomas Asheim Smedmann on 09/09/2021.
//

import UIKit


enum RatingThreshold: Int {
    case low = 4    // 1..<4 = low
    case high = 8   // 8..<11 = high
}

@IBDesignable
class RatingView: UIView {
    private static let dotWidth: CGFloat = 10
    private static let ratingLabelMargin: CGFloat = 1
    
    private static let maxRating = 10
    
    private let container: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: (0..<maxRating).map { _ in
            var circularView = CircularView()
            circularView.backgroundColor = .white
            circularView.translatesAutoresizingMaskIntoConstraints = false
            circularView.widthAnchor.constraint(equalToConstant: dotWidth).isActive = true
            circularView.heightAnchor.constraint(equalTo: circularView.widthAnchor).isActive = true
            return circularView
        })
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = dotWidth
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        return label
    }()
    
    @IBInspectable var rating: Int = 0 {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override var intrinsicContentSize: CGSize {
        let width = rating > 0
            ? RatingView.dotWidth * 2 * CGFloat(RatingView.maxRating) + ratingLabel.intrinsicContentSize.width + 2 * RatingView.ratingLabelMargin
            : RatingView.dotWidth * 2 * CGFloat(RatingView.maxRating) + RatingView.dotWidth

        let height = rating > 0
            ? ratingLabel.intrinsicContentSize.height + 2 * RatingView.ratingLabelMargin
            : RatingView.dotWidth

        return CGSize(width: width, height: height)
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        
        container.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        container.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        container.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
        container.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func updateUI() {
        if let dotView = ratingLabel.superview {
            dotView.backgroundColor = .white
            dotView.constraints.first(where: { $0.firstAttribute == .width })?.constant = RatingView.dotWidth
            ratingLabel.removeFromSuperview()
        }
        
        let index = rating - 1
        guard
            index > -1, index < container.arrangedSubviews.count
        else { return }
        
        let dotView = container.arrangedSubviews[index]
        
        ratingLabel.text = "\(rating)"
        
        dotView.addSubview(ratingLabel)
        dotView.backgroundColor = rating < RatingThreshold.high.rawValue
            ? rating < RatingThreshold.low.rawValue ? .red : .white
            : .green
        
        ratingLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor).isActive = true
        ratingLabel.centerXAnchor.constraint(equalTo: dotView.centerXAnchor).isActive = true
        
        dotView.constraints.first(where: { $0.firstAttribute == .width })?.constant = ratingLabel.intrinsicContentSize.height + RatingView.ratingLabelMargin * 2
    }
}

