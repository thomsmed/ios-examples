# Touch gestures and SpriteKit

DISCLAIMER: All assets has been generated with the help of ChatGPT.

A simple SpriteKit app showing how to detect and handle multiple touch gestures.

The app let you:

- Move a player sprite around in the game world (using one finger)
- Drag, scale and rotate any other node in the game world (using two fingers)
- Pan around in the game world (using two fingers)
- Zoom in/out on any arbitrary point in the game world (using two fingers)
- Rotate around any arbitrary point in the game world (using two fingers)

[Allowing the simultaneous recognition of multiple gestures](https://developer.apple.com/documentation/uikit/allowing-the-simultaneous-recognition-of-multiple-gestures).

## Pan

[Handling pan gestures](https://developer.apple.com/documentation/uikit/handling-pan-gestures).

### Moving the Camera around

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var lastPanGestureTranslation: CGPoint = .zero

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
    }
}

extension GameScene {

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let translationInView = sender.translation(in: view)
        let velocityInView = sender.velocity(in: view)

        defer { lastPanGestureTranslation = translationInView }

        guard case .changed = sender.state else {
            return
        }

        let dTranslation = CGPoint(
            x: translationInView.x - lastPanGestureTranslation.x,
            y: lastPanGestureTranslation.y - translationInView.y
        )

        let offsetInScene = dTranslation
            .applying(CGAffineTransform(scaleX: gameWorldCamera.xScale, y: gameWorldCamera.yScale))
            .applying(CGAffineTransform(rotationAngle: gameWorldCamera.zRotation))

        gameWorldCamera.position = gameWorldCamera.position
            .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```

### Moving a Node around

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var gestureTargetNode: SKNode? = nil

    var lastPanGestureTranslation: CGPoint = .zero

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
    }
}

extension GameScene {

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let translationInView = sender.translation(in: view)
        let velocityInView = sender.velocity(in: view)

        defer { lastPanGestureTranslation = translationInView }

        switch sender.state {
        case .began:
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)

            gestureTargetNode =
                if frontTouchedNode != self {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            guard let targetNode = gestureTargetNode else {
                return
            }

            let dTranslation = CGPoint(
                x: translationInView.x - lastPanGestureTranslation.x,
                y: lastPanGestureTranslation.y - translationInView.y
            )

            let offsetInScene = dTranslation
                .applying(CGAffineTransform(scaleX: gameWorldCamera.xScale, y: gameWorldCamera.yScale))
                .applying(CGAffineTransform(rotationAngle: gameWorldCamera.zRotation))

            let transformedTargetNodePositionInScene = convert(targetNode.position, from: targetNode.parent ?? self)
                .applying(CGAffineTransform(translationX: offsetInScene.x, y: offsetInScene.y))

            targetNode.position = convert(transformedTargetNodePositionInScene, to: targetNode.parent ?? self)

        default:
            break
        }
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```

## Pinch

[Handling pinch gestures](https://developer.apple.com/documentation/uikit/handling-pinch-gestures).

### Zooming in and out with the Camera

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var lastPinchGestureScale: CGFloat = 1

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)
    }
}

extension GameScene {

    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let scale = sender.scale
        let velocityInView = sender.velocity

        defer { lastPinchGestureScale = scale }

        guard case .changed = sender.state else {
            return
        }

        let dScale = lastPinchGestureScale - scale

        let locationInSceneBeforeScaling = view.convert(locationInView, to: self)
        gameWorldCamera.xScale += dScale * gameWorldCamera.xScale
        gameWorldCamera.yScale += dScale * gameWorldCamera.yScale
        let locationInSceneAfterScaling = view.convert(locationInView, to: self)

        let offsetInScene = CGPoint(
            x: locationInSceneAfterScaling.x - locationInSceneBeforeScaling.x,
            y: locationInSceneAfterScaling.y - locationInSceneBeforeScaling.y
        )

        gameWorldCamera.position = gameWorldCamera.position
            .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```

### Scaling a Node up and down

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var gestureTargetNode: SKNode? = nil

    var lastPinchGestureScale: CGFloat = 1

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)
    }
}

extension GameScene {

    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let scale = sender.scale
        let velocityInView = sender.velocity

        defer { lastPinchGestureScale = scale }

        switch sender.state {
        case .began:
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)

            gestureTargetNode =
                if frontTouchedNode != self {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            guard let targetNode = gestureTargetNode else {
                return
            }

            let dScale = lastPinchGestureScale - scale

            let locationInTargetNodeBeforeScaling = targetNode.convert(view.convert(locationInView, to: self), from: self)
            targetNode.xScale -= dScale * targetNode.xScale
            targetNode.yScale -= dScale * targetNode.yScale
            let locationInTargetNodeAfterScaling = targetNode.convert(view.convert(locationInView, to: self), from: self)

            let offsetInTargetNode = CGPoint(
                x: locationInTargetNodeAfterScaling.x - locationInTargetNodeBeforeScaling.x,
                y: locationInTargetNodeAfterScaling.y - locationInTargetNodeBeforeScaling.y
            )

            targetNode.position = targetNode.convert(offsetInTargetNode, to: targetNode.parent ?? self)

        default:
            break
        }
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```

## Rotate

[Handling rotation gestures](https://developer.apple.com/documentation/uikit/handling-rotation-gestures).

### Rotating the Camera

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var lastRotationGestureRotation: CGFloat = .zero

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture))
        rotationRecognizer.delegate = self
        view.addGestureRecognizer(rotationRecognizer)
    }
}

extension GameScene {

    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let rotation = sender.rotation
        let velocityInView = sender.velocity

        defer { lastRotationGestureRotation = rotation }

        guard case .changed = sender.state else {
            return
        }

        let dRotation = rotation - lastRotationGestureRotation

        let locationInSceneBeforeRotation = view.convert(locationInView, to: self)
        gameWorldCamera.zRotation += dRotation
        let locationInSceneAfterRotation = view.convert(locationInView, to: self)

        let offsetInScene = CGPoint(
            x: locationInSceneAfterRotation.x - locationInSceneBeforeRotation.x,
            y: locationInSceneAfterRotation.y - locationInSceneBeforeRotation.y
        )

        gameWorldCamera.position = gameWorldCamera.position
            .applying(CGAffineTransform(translationX: -offsetInScene.x, y: -offsetInScene.y))
    }
}

extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```

### Rotating a Node

```swift
class GameScene: SKScene {

    let gameWorldCamera = SKCameraNode()

    var gestureTargetNode: SKNode? = nil

    var lastRotationGestureRotation: CGFloat = .zero

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera)
        camera = gameWorldCamera
        listener = gameWorldCamera

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture))
        rotationRecognizer.delegate = self
        view.addGestureRecognizer(rotationRecognizer)
    }
}

extension GameScene {

    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let view else { return }

        let locationInView = sender.location(in: view)
        let rotation = sender.rotation
        let velocityInView = sender.velocity

        defer { lastRotationGestureRotation = rotation }

        switch sender.state {
        case .began:
            let locationInScene = view.convert(locationInView, to: self)
            let frontTouchedNode = atPoint(locationInScene)

            gestureTargetNode =
                if frontTouchedNode != self {
                    frontTouchedNode
                } else {
                    nil
                }

        case .changed:
            guard let targetNode = gestureTargetNode else {
                return
            }

            let dRotation = rotation - lastRotationGestureRotation

            let locationInTargetNodeBeforeRotation = targetNode.convert(view.convert(locationInView, to: self), from: self)
            targetNode.zRotation -= dRotation
            let locationInTargetNodeAfterRotation = targetNode.convert(view.convert(locationInView, to: self), from: self)

            let offsetInTargetNode = CGPoint(
                x: locationInTargetNodeAfterRotation.x - locationInTargetNodeBeforeRotation.x,
                y: locationInTargetNodeAfterRotation.y - locationInTargetNodeBeforeRotation.y
            )

            targetNode.position = targetNode.convert(offsetInTargetNode, to: targetNode.parent ?? self)

        default:
            break
        }
    }
}


extension GameScene: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allows for UIPanGestureRecognizer, UIPinchGestureRecognizer,
        // UIRotationGestureRecognizer and the SKScene to all process touch events.
        true
    }
}
```
