//
//  TextInputSheetViewController.swift
//  BottomSheetController
//
//  Created by hyonsoo on 1/7/24.
//

import UIKit
import Combine
import SwiftUI

final class TextInputSheetViewController: BottomSheetController {

    static let defaultBottomPadding: CGFloat = 30
    private var movingBottomConstraint: NSLayoutConstraint?
    private var cancellables: Set<AnyCancellable> = []
    
    override func loadView() {
        view = UIView()

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = "Hello! 👋"
        label.setContentHuggingPriority(.required, for: .vertical)

        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.addAction(.init(handler: { _ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
        button.backgroundColor = .systemGray5
        button.setContentHuggingPriority(.required, for: .vertical)
        
        let input = UITextField()
        input.placeholder = "Type text.."
        input.setContentCompressionResistancePriority(.required, for: .vertical)
        input.setContentHuggingPriority(.required, for: .vertical)

        // mark safe area
        let bottomSafeArea = UIView()
        bottomSafeArea.backgroundColor = .yellow
        
        view.addSubview(button)
        view.addSubview(label)
        view.addSubview(input)
        view.addSubview(bottomSafeArea)

        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        input.translatesAutoresizingMaskIntoConstraints = false
        bottomSafeArea.translatesAutoresizingMaskIntoConstraints = false

        movingBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: input.bottomAnchor, constant: Self.defaultBottomPadding)
        movingBottomConstraint?.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),

            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            input.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            movingBottomConstraint!,
            input.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            input.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            bottomSafeArea.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSafeArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomSafeArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        view.backgroundColor = .systemBackground
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { notification in
                self.handleKeyboardWillShowHide(notification, show: true)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { notification in
                self.handleKeyboardWillShowHide(notification, show: false)
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyboardWillShowHide(_ notification: Notification, show: Bool) {
        // In iOS 16.1 and later, the keyboard notification object is the screen the keyboard appears on.
        let screen: UIScreen?
        if #available(iOS 16.1, *) {
            screen = notification.object as? UIScreen
        } else {
            screen = self.findKeyWindow()?.screen
        }
        guard let userInfo = notification.userInfo, let screen = screen else { return }
        guard let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        // Use that screen to get the coordinate space to convert from.
        let fromCoordinateSpace = screen.coordinateSpace
        // Get your view's coordinate space.
        let toCoordinateSpace: UICoordinateSpace = self.view
        // Convert the keyboard's frame from the screen's coordinate space to your view's coordinate space.
        let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)
        // Get the safe area insets when the keyboard is offscreen.
        let bottomOffset = view.safeAreaInsets.bottom
        
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = (userInfo[durationKey] as? Double) ?? 0.24
        
        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = (userInfo[curveKey] as? Int) ?? UIView.AnimationCurve.easeOut.rawValue
        let curve = UIView.AnimationCurve(rawValue: curveValue)!
        
        let targetOffset = show ? convertedKeyboardFrameEnd.height - bottomOffset + Self.defaultBottomPadding : Self.defaultBottomPadding
        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            // Perform the necessary animation layout updates
            self.movingBottomConstraint?.constant = targetOffset
            // Required to trigger NSLayoutConstraint changes to animate
            self.view?.layoutIfNeeded()
        }
        
        // Start the animation
        animator.startAnimation()
    }
    
    private func findKeyWindow() -> UIWindow? {
        if #available(iOS 15, *) {
            return UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
                .sorted(by: { $0.activationState.priority < $1.activationState.priority })
                .compactMap({ $0.windows.filter({ $0.isKeyWindow }).first })
                .first
        } else {
            return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
        }
    }
}

#Preview {
    UIViewControllerPreview {
        TextInputSheetViewController()
    }
}

fileprivate extension UIScene.ActivationState {
    var priority: Int {
        switch self {
        case .foregroundActive: return 0
        case .foregroundInactive: return 1
        case .background: return 2
        case .unattached: return 3
        default:
            return 100
        }
    }
}
