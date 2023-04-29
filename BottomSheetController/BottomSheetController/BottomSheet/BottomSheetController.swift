//
//  BottomSheetController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

/// Use `BottomSheetController` as the basis for your bottom sheet. Subclass it or use it as is.
/// You add subviews and child view controllers as you would with every other view/view controller.
///
/// The `BottomSheetController` installs its own `UIViewControllerTransitioningDelegate`
/// and forces `UIModalPresentationStyle` to `UIModalPresentationStyle.custom`.
/// Present it as you would present any other `UIViewController`, using `UIViewController.present(_:)`.
class BottomSheetController: UIViewController {

    /// Enum that specify how the sheet should size it self based on its content.
    /// The sheet sizing act as a loose anchor on how big the sheet should be, and the sheet will always respect its content's constraints.
    /// However, the sheet will never extend beyond the top safe area (plus any stretch offset).
    enum PreferredSheetSizing: CGFloat {
        /// The sheet will try to size it self so that it only just fits its content.
        case fit = 0
        /// The sheet will try to size it self so that it fills 1/4 of available space.
        case small = 0.25
        /// The sheet will try to size it self so that it fills 1/2 of available space.
        case medium = 0.5
        /// The sheet will try to size it self so that it fills 3/4 of available space.
        case large = 0.75
        /// The sheet will try to size it self so that it fills all available space.
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

    /// Preferred space between the sheet's max stretch height and the safe area.
    /// Defaults to 0.
    var preferredSheetTopInset: CGFloat = 0 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }

    /// Preferred corner radius of the sheet's top left and right corner.
    /// Defaults to 8.
    var preferredSheetCornerRadius: CGFloat = 8 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    /// Preferred sheet sizing. See `PreferredSheetSizing` for all available options.
    /// Defaults to `PreferredSheetSizing.medium`.
    var preferredSheetSizing: PreferredSheetSizing = .medium {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    /// Preferred sheet backdrop color. This is the color of the overlay/backdrop view behind the sheet.
    /// Defaults to `UIColor.label`.
    var preferredSheetBackdropColor: UIColor = .label {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
        }
    }

    /// Boolean to specify if it should be possible to dismiss the sheet by tapping the backdrop.
    /// Defaults to true.
    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }

    /// Boolean to specify if it should be possible to dismiss the sheet by dragging it down.
    /// Defaults to true.
    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}
