//
//  BottomSheetController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

class BottomSheetController: UIViewController {

    enum PreferredSheetSizing: CGFloat {
        case fit = 0
        case small = 0.25
        case medium = 0.5
        case large = 1
    }

    private lazy var bottomSheetTransitioningDelegate: BottomSheetTransitioningDelegate = {
        let bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
            preferredSheetSizingFactor: preferredSheetSizing.rawValue,
            preferredSheetCornerRadius: preferredSheetCornerRadius
        )
        additionalSafeAreaInsets = .zero
        return bottomSheetTransitioningDelegate
    }()

    override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            super.additionalSafeAreaInsets
        }
        set {
            let insets: UIEdgeInsets = .init(
                top: newValue.top + preferredSheetCornerRadius,
                left: newValue.left,
                bottom: newValue.bottom,
                right: newValue.right
            )
            super.additionalSafeAreaInsets = insets
        }
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }

    var preferredSheetCornerRadius: CGFloat = 8 {
        didSet {
            additionalSafeAreaInsets = .init(
                top: additionalSafeAreaInsets.top - oldValue,
                left: additionalSafeAreaInsets.left,
                bottom: additionalSafeAreaInsets.bottom,
                right: additionalSafeAreaInsets.right
            )
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    var preferredSheetSizing: PreferredSheetSizing = .medium {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}
