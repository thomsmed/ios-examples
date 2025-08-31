//
//  GameScene+Input.swift
//  GesturesAndSpriteKit
//
//  Created by Thomas Smedmann on 31/08/2025.
//

import Foundation
import OSLog
import SpriteKit

extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        Logger.game.debug("touchesBegan")

        guard let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: self)

        let frontTouchedNode = atPoint(touchLocation)

        if frontTouchedNode == player {
            gameInput.activePlayerTouch = touch
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        Logger.game.debug("touchesMoved")

        guard let player else {
            return
        }

        guard let activePlayerTouch = gameInput.activePlayerTouch else {
            return
        }

        guard touches.contains(activePlayerTouch) else {
            return
        }

        let touchLocation = activePlayerTouch.location(in: self)
        let previousTouchLocation = activePlayerTouch.previousLocation(in: self)

        let offset = CGPoint(
            x: touchLocation.x - previousTouchLocation.x,
            y: touchLocation.y - previousTouchLocation.y
        )

        player.position = player.position
            .applying(CGAffineTransform(translationX: offset.x, y: offset.y))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        Logger.game.debug("touchesEnded")

        guard let activePlayerTouch = gameInput.activePlayerTouch else {
            return
        }

        guard touches.contains(activePlayerTouch) else {
            return
        }

        gameInput.activePlayerTouch = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        Logger.game.debug("touchesCancelled")
    }
}

extension GameScene {

    /// [Handling pan gestures](https://developer.apple.com/documentation/uikit/handling-pan-gestures).
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let translationInView = sender.translation(in: view)
        let velocityInView = sender.velocity(in: view)

        defer { gameInput.lastPanGestureTranslation = translationInView }

        switch sender.state {
        case .possible:
            Logger.game.debug("handlePanGesture, state: .possible (locationInView: \("\(locationInView)")")

        case .began:
            Logger.game.debug("handlePanGesture, state: .began (translationInView: \("\(translationInView)")")
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)
            gameInput.gestureTargetNode =
                if frontTouchedNode != self, frontTouchedNode != player {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            let dTranslation = CGPoint(
                x: translationInView.x - gameInput.lastPanGestureTranslation.x,
                y: gameInput.lastPanGestureTranslation.y - translationInView.y
            )

            if let targetNode = gameInput.gestureTargetNode {
                let offsetInScene = dTranslation
                    .applying(CGAffineTransform(scaleX: gameWorldCamera.root.xScale, y: gameWorldCamera.root.yScale))
                    .applying(CGAffineTransform(rotationAngle: gameWorldCamera.root.zRotation))

                let transformedTargetNodePositionInScene = convert(targetNode.position, from: targetNode.parent ?? self)
                    .applying(CGAffineTransform(translationX: offsetInScene.x, y: offsetInScene.y))

                Logger.game.debug("handlePanGesture, state: .began (offsetInScene: \("\(offsetInScene)")")

                targetNode.position = convert(transformedTargetNodePositionInScene, to: targetNode.parent ?? self)
            } else {
                let offsetInScene = dTranslation
                    .applying(CGAffineTransform(scaleX: gameWorldCamera.root.xScale, y: gameWorldCamera.root.yScale))
                    .applying(CGAffineTransform(rotationAngle: gameWorldCamera.root.zRotation))

                Logger.game.debug("handlePanGesture, state: .began (offsetInScene: \("\(offsetInScene)")")

                gameWorldCamera.root.position = gameWorldCamera.root.position
                    .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
            }

        case .ended:
            Logger.game.debug("handlePanGesture, state: .ended (velocityInView: \("\(velocityInView)"))")

        case .cancelled:
            Logger.game.debug("handlePanGesture, state: .cancelled")

        case .failed:
            Logger.game.debug("handlePanGesture, state: .failed")

        @unknown default:
            fatalError("Why did this happen?")
        }
    }

    /// [Handling pinch gestures](https://developer.apple.com/documentation/uikit/handling-pinch-gestures).
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let scale = sender.scale
        let velocityInView = sender.velocity

        defer { gameInput.lastPinchGestureScale = scale }

        switch sender.state {
        case .possible:
            Logger.game.debug("handlePinchGesture, state: .possible (locationInView: \("\(locationInView)")")

        case .began:
            Logger.game.debug("handlePinchGesture, state: .began (scale: \(scale))")
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)
            gameInput.gestureTargetNode =
                if frontTouchedNode != self, frontTouchedNode != player {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            let dScale = gameInput.lastPinchGestureScale - scale

            if let targetNode = gameInput.gestureTargetNode {
                let locationInTargetNodeBeforeScaling = targetNode.convert(view.convert(locationInView, to: self), from: self)
                targetNode.xScale -= dScale * targetNode.xScale
                targetNode.yScale -= dScale * targetNode.yScale
                let locationInTargetNodeAfterScaling = targetNode.convert(view.convert(locationInView, to: self), from: self)

                let offsetInTargetNode = CGPoint(
                    x: locationInTargetNodeAfterScaling.x - locationInTargetNodeBeforeScaling.x,
                    y: locationInTargetNodeAfterScaling.y - locationInTargetNodeBeforeScaling.y
                )

                Logger.game.debug("handlePinchGesture, state: .changed (scale: \(scale), offsetInTargetNode: \("\(offsetInTargetNode)")")

                targetNode.position = targetNode.convert(offsetInTargetNode, to: targetNode.parent ?? self)
            } else {
                let locationInSceneBeforeScaling = view.convert(locationInView, to: self)
                gameWorldCamera.root.xScale += dScale * gameWorldCamera.root.xScale
                gameWorldCamera.root.yScale += dScale * gameWorldCamera.root.yScale
                let locationInSceneAfterScaling = view.convert(locationInView, to: self)

                let offsetInScene = CGPoint(
                    x: locationInSceneAfterScaling.x - locationInSceneBeforeScaling.x,
                    y: locationInSceneAfterScaling.y - locationInSceneBeforeScaling.y
                )

                Logger.game.debug("handlePinchGesture, state: .changed (scale: \(scale), offsetInScene: \("\(offsetInScene)")")

                gameWorldCamera.root.position = gameWorldCamera.root.position
                    .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
            }

        case .ended:
            Logger.game.debug("handlePinchGesture, state: .ended (velocityInView: \(velocityInView))")

        case .cancelled:
            Logger.game.debug("handlePinchGesture, state: .cancelled")

        case .failed:
            Logger.game.debug("handlePinchGesture, state: .failed")

        @unknown default:
            fatalError("Why did this happen?")
        }
    }

    /// [Handling rotation gestures](https://developer.apple.com/documentation/uikit/handling-rotation-gestures).
    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let rotation = sender.rotation
        let velocityInView = sender.velocity

        defer { gameInput.lastRotationGestureRotation = rotation }

        switch sender.state {
        case .possible:
            Logger.game.debug("handleRotationGesture, state: .possible (locationInView: \("\(locationInView)")")

        case .began:
            Logger.game.debug("handleRotationGesture, state: .began (rotation: \(rotation))")
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)
            gameInput.gestureTargetNode =
                if frontTouchedNode != self, frontTouchedNode != player {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            let dRotation = rotation - gameInput.lastRotationGestureRotation

            if let targetNode = gameInput.gestureTargetNode {
                let locationInTargetNodeBeforeRotation = targetNode.convert(view.convert(locationInView, to: self), from: self)
                targetNode.zRotation -= dRotation
                let locationInTargetNodeAfterRotation = targetNode.convert(view.convert(locationInView, to: self), from: self)

                let offsetInTargetNode = CGPoint(
                    x: locationInTargetNodeAfterRotation.x - locationInTargetNodeBeforeRotation.x,
                    y: locationInTargetNodeAfterRotation.y - locationInTargetNodeBeforeRotation.y
                )

                Logger.game.debug("handleRotationGesture, state: .changed (rotation: \(rotation), offsetInTargetNode: \("\(offsetInTargetNode)")")

                targetNode.position = targetNode.convert(offsetInTargetNode, to: targetNode.parent ?? self)
            } else {
                let locationInSceneBeforeRotation = view.convert(locationInView, to: self)
                gameWorldCamera.root.zRotation += dRotation
                let locationInSceneAfterRotation = view.convert(locationInView, to: self)

                let offsetInScene = CGPoint(
                    x: locationInSceneAfterRotation.x - locationInSceneBeforeRotation.x,
                    y: locationInSceneAfterRotation.y - locationInSceneBeforeRotation.y
                )

                Logger.game.debug("handleRotationGesture, state: .changed (rotation: \(rotation), offsetInScene: \("\(offsetInScene)")")

                gameWorldCamera.root.position = gameWorldCamera.root.position
                    .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
            }

        case .ended:
            Logger.game.debug("handleRotationGesture, state: .ended (velocityInView: \(velocityInView))")

        case .cancelled:
            Logger.game.debug("handleRotationGesture, state: .cancelled")

        case .failed:
            Logger.game.debug("handleRotationGesture, state: .failed")

        @unknown default:
            fatalError("Why did this happen?")
        }
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    /// [Allowing the simultaneous recognition of multiple gestures](https://developer.apple.com/documentation/uikit/allowing-the-simultaneous-recognition-of-multiple-gestures).
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}

