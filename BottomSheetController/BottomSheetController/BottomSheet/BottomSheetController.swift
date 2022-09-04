//
//  BottomSheetController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

class BottomSheetController: UIViewController {

    enum PreferredSheetSizing: CGFloat {
        case fit = 0 // Fit, based on the view's constraints
        case small = 0.25
        case medium = 0.5
        case large = 0.75
        case fill = 1
    }

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        preferredSheetTopInset: preferredSheetTopInset,
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetSizingFactor: preferredSheetSizing.rawValue,
        preferredSheetBackdropColor: preferredSheetBackdropColor
    )

    override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            .init(
                top: super.additionalSafeAreaInsets.top + preferredSheetCornerRadius,
                left: super.additionalSafeAreaInsets.left,
                bottom: super.additionalSafeAreaInsets.bottom,
                right: super.additionalSafeAreaInsets.right
            )
        }
        set {
            super.additionalSafeAreaInsets = newValue
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

    var preferredSheetTopInset: CGFloat = 24 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }

    var preferredSheetCornerRadius: CGFloat = 8 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    var preferredSheetSizing: PreferredSheetSizing = .medium {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    var preferredSheetBackdropColor: UIColor = .label {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
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
