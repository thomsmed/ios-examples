//
//  TableFooterView.swift
//  DynamicTableHeaderView
//
//  Created by Thomas Asheim Smedmann on 19/08/2022.
//

import UIKit

final class TableFooterView: UIView {

    typealias Model = [(title: String, imageName: String)]

//    private let collectionView: UICollectionView = {
//        let collectionView = UICollectionView()
//        return collectionView
//    }()

    private lazy var collapsedConstraints: [NSLayoutConstraint] = [

    ]

    private lazy var expandedConstraints: [NSLayoutConstraint] = [

    ]

    var model: Model? = nil {
        didSet {

        }
    }

    var expanded: Bool = false {
        didSet {
            (superview as? UITableView)?.beginUpdates()

            // TODO: Explain the animation duration
            UIView.animate(withDuration: 0.3) {
                if self.expanded {
                    NSLayoutConstraint.deactivate(self.collapsedConstraints)
                    NSLayoutConstraint.activate(self.expandedConstraints)
                } else {
                    NSLayoutConstraint.deactivate(self.expandedConstraints)
                    NSLayoutConstraint.activate(self.collapsedConstraints)
                }
            }

            (superview as? UITableView)?.endUpdates()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeContent(in: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func placeContent(in view: UIView) {


        NSLayoutConstraint.activate(collapsedConstraints)
    }
}
