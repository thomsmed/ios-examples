//
//  GameScene.swift
//  GesturesAndSpriteKit
//
//  Created by Thomas Smedmann on 31/08/2025.
//

import Foundation
import OSLog
import SpriteKit

struct GameWorldCamera {

    struct SafeArea {
        let size: CGSize
        let leftInset: CGFloat
        let rightInset: CGFloat
        let topInset: CGFloat
        let bottomInset: CGFloat

        static var zero: SafeArea {
            SafeArea(size: .zero, leftInset: .zero, rightInset: .zero, topInset: .zero, bottomInset: .zero)
        }
    }

    let root: SKCameraNode
    let size: CGSize
    let safeArea: SafeArea
}

struct GameWorld {
    let root: SKNode
    let camera: GameWorldCamera
}

struct GameInput {
    var lastCurrentTime: TimeInterval? = nil
    var activePlayerTouch: UITouch? = nil
    var gestureTargetNode: SKNode? = nil
    var lastPanGestureTranslation: CGPoint = .zero
    var lastPinchGestureScale: CGFloat = 1
    var lastRotationGestureRotation: CGFloat = .zero
}

@MainActor final class GameScene: SKScene {

    var gameWorldCamera: GameWorldCamera = GameWorldCamera(root: SKCameraNode(), size: .zero, safeArea: .zero)
    var gameInput: GameInput = GameInput()

    var rootSquare: SKShapeNode? = nil
    var player: SKSpriteNode? = nil
    var sun: SKSpriteNode? = nil

    override init() {
        super.init(size: .zero)

        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addChild(gameWorldCamera.root)
        camera = gameWorldCamera.root
        listener = gameWorldCamera.root

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture))
        rotationRecognizer.delegate = self
        view.addGestureRecognizer(rotationRecognizer)

        let worldCameraSize = size
        let worldCameraSafeArea = GameWorldCamera.SafeArea(
            size: view.safeAreaLayoutGuide.layoutFrame.size,
            leftInset: view.safeAreaInsets.left,
            rightInset: view.safeAreaInsets.right,
            topInset: view.safeAreaInsets.top,
            bottomInset: view.safeAreaInsets.bottom
        )

        let worldCamera = GameWorldCamera(
            root: gameWorldCamera.root, size: worldCameraSize, safeArea: worldCameraSafeArea
        )

        start(with: worldCamera)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        guard let view else { return }

        let newWorldCameraSize = size
        let newWorldCameraSafeArea = GameWorldCamera.SafeArea(
            size: view.safeAreaLayoutGuide.layoutFrame.size,
            leftInset: view.safeAreaInsets.left,
            rightInset: view.safeAreaInsets.right,
            topInset: view.safeAreaInsets.top,
            bottomInset: view.safeAreaInsets.bottom
        )

        let newWorldCamera = GameWorldCamera(
            root: gameWorldCamera.root, size: newWorldCameraSize, safeArea: newWorldCameraSafeArea
        )

        adapt(to: newWorldCamera)
    }
}

extension GameScene {

    func resetWorld() {
        let cameraPosition = CGPoint(
            x: gameWorldCamera.size.width / 2 - gameWorldCamera.safeArea.leftInset,
            y: gameWorldCamera.size.height / 2 - gameWorldCamera.safeArea.bottomInset
        )
        let resetCamera: SKAction = .group([
            .scale(to: 1, duration: 0.5),
            .move(to: cameraPosition, duration: 0.5),
            .rotate(toAngle: 0, duration: 0.5)
        ])
        gameWorldCamera.root.run(resetCamera, withKey: "ResetCamera")

        if let rootSquare {
            let rootSquarePosition = CGPoint(
                x: gameWorldCamera.safeArea.size.width / 2,
                y: gameWorldCamera.safeArea.size.height / 2,
            )
            let resetSquares: SKAction = .group([
                .scale(to: 1, duration: 0.5),
                .move(to: rootSquarePosition, duration: 0.5),
                .rotate(toAngle: 0, duration: 0.5),
                .run {
                    let resetChildSquare: SKAction = .group([
                        .scale(to: 1, duration: 0.5),
                        .move(to: .zero, duration: 0.5),
                        .rotate(toAngle: 0, duration: 0.5)
                    ])
                    rootSquare.children.forEach { childNode in
                        childNode.run(resetChildSquare, withKey: "ResetChildSquare")
                    }
                }
            ])
            rootSquare.run(resetSquares, withKey: "ResetSquares")
        }

        if let player {
            let playerPosition = CGPoint(
                x: gameWorldCamera.safeArea.size.width / 2,
                y: gameWorldCamera.safeArea.size.height / 2,
            )
            let resetPlayer: SKAction = .group([
                .scale(to: 1, duration: 0.5),
                .move(to: playerPosition, duration: 0.5),
                .rotate(toAngle: 0, duration: 0.5)
            ])
            player.run(resetPlayer, withKey: "ResetPlayer")
        }

        if let sun {
            let sunPosition = CGPoint(
                x: gameWorldCamera.safeArea.size.width * 0.75,
                y: gameWorldCamera.safeArea.size.height * 0.75,
            )
            let resetSun: SKAction = .group([
                .scale(to: 1, duration: 0.5),
                .move(to: sunPosition, duration: 0.5),
                .rotate(toAngle: 0, duration: 0.5)
            ])
            sun.run(resetSun, withKey: "ResetSun")
        }
    }
}

extension GameScene {

    func start(with gameWorldCamera: GameWorldCamera) {
        gameWorldCamera.root.position = CGPoint(
            x: gameWorldCamera.size.width / 2 - gameWorldCamera.safeArea.leftInset,
            y: gameWorldCamera.size.height / 2 - gameWorldCamera.safeArea.bottomInset
        )
        self.gameWorldCamera = gameWorldCamera

        let gameWorld = GameWorld(root: self, camera: self.gameWorldCamera)

        Self.spawnRedAndYellowSquares(in: gameWorld) { rootSquare in
            self.rootSquare = rootSquare
        }

        Self.uniquelySpawnPlayer(in: gameWorld) { player in
            self.player = player
        }

        Self.uniquelySpawnSun(in: gameWorld) { sun in
            self.sun = sun
        }
    }

    func adapt(to newGameWorldCamera: GameWorldCamera) {
        let uniqueActionName = "GameResize"

        let _ = GameWorld(root: self, camera: self.gameWorldCamera)
        let newWorld = GameWorld(root: self, camera: newGameWorldCamera)

        let resizeGame: SKAction = .sequence([
            .run {
                Logger.game.debug("Resizing Game World")

                // Optionally adapt and reposition nodes here...

                self.gameWorldCamera = newGameWorldCamera
            }
        ])
        newWorld.root.run(resizeGame, withKey: uniqueActionName)
    }
}
