//
//  GameScene+Mechanics.swift
//  GesturesAndSpriteKit
//
//  Created by Thomas Smedmann on 31/08/2025.
//

import Foundation
import OSLog
import SpriteKit

extension GameScene {

    @MainActor static func spawnRedAndYellowSquares(in gameWorld: GameWorld, completion: @escaping (SKShapeNode) -> Void) {
        let redSquareDimension = min(gameWorld.camera.safeArea.size.width / 2, gameWorld.camera.safeArea.size.height / 2)
        let redSquareSize = CGSize(width: redSquareDimension, height: redSquareDimension)
        let redSquarePosition = CGPoint(
            x: gameWorld.camera.safeArea.size.width / 2,
            y: gameWorld.camera.safeArea.size.height / 2,
        )

        let redSquareNode = SKShapeNode(rectOf: redSquareSize)
        redSquareNode.strokeColor = .systemRed
        redSquareNode.lineWidth = 4
        redSquareNode.position = redSquarePosition

        let yellowSquareDimension = min(gameWorld.camera.safeArea.size.width / 3, gameWorld.camera.safeArea.size.height / 3)
        let yellowSquareSize = CGSize(width: yellowSquareDimension, height: yellowSquareDimension)

        let yellowSquareNode = SKShapeNode(rectOf: yellowSquareSize)
        yellowSquareNode.strokeColor = .systemYellow
        yellowSquareNode.lineWidth = 4
        yellowSquareNode.zRotation = .pi / 2

        redSquareNode.addChild(yellowSquareNode)

        yellowSquareNode.constraints = [
            .distance(.init(lowerLimit: 0, upperLimit: 200), to: redSquareNode)
        ]

        gameWorld.root.addChild(redSquareNode)

        // Animate the squares into the world:

        redSquareNode.alpha = 0
        redSquareNode.zRotation = .pi * 2

        let rotateAndFadeIn: SKAction = .sequence([
            .group([
                .rotate(toAngle: 0, duration: 0.5),
                .fadeIn(withDuration: 0.5),
            ]),
            .run {
                completion(redSquareNode)
            },
        ])

        redSquareNode.run(rotateAndFadeIn)
    }

    @MainActor static func uniquelySpawnPlayer(in gameWorld: GameWorld, completion: @escaping (SKSpriteNode) -> Void) {
        let uniqueNodeName = "Player"

        let playerDimension = min(gameWorld.camera.safeArea.size.width, gameWorld.camera.safeArea.size.height) * 0.1
        let playerSize = CGSize(
            width: playerDimension,
            height: playerDimension
        )
        let playerPosition = CGPoint(
            x: gameWorld.camera.safeArea.size.width / 2,
            y: gameWorld.camera.safeArea.size.height / 2,
        )
        let playerSpawnPosition = CGPoint(
            x: gameWorld.camera.safeArea.size.width / 2,
            y: 0
        )

        let playerNode = SKSpriteNode()
        playerNode.size = playerSize

        let playerAnimationFrames = [
            SKTexture(imageNamed: "player_ship_frame1"),
            SKTexture(imageNamed: "player_ship_frame2"),
            SKTexture(imageNamed: "player_ship_frame3"),
        ]
        let playerAnimation: SKAction = .repeatForever(
            .animate(
                with: playerAnimationFrames,
                timePerFrame: 0.10,
                resize: false,
                restore: true
            )
        )
        playerNode.run(playerAnimation)

        playerNode.position = playerSpawnPosition
        playerNode.zPosition = 1
        playerNode.name = uniqueNodeName

        gameWorld.root[uniqueNodeName].forEach { $0.removeFromParent() }

        gameWorld.root.addChild(playerNode)

        // Animate the player ship into the world:

        playerNode.alpha = 0

        let fadeInAndLand: SKAction = .sequence([
            .fadeIn(withDuration: 0.5),
            .move(to: playerPosition, duration: 0.5),
            .run {
                completion(playerNode)
            },
        ])

        playerNode.run(fadeInAndLand)
    }

    @MainActor static func uniquelySpawnSun(in gameWorld: GameWorld, completion: @escaping (SKSpriteNode) -> Void) {
        let uniqueNodeName = "SmilingSun"

        let sunDimension = min(gameWorld.camera.safeArea.size.width, gameWorld.camera.safeArea.size.height) * 0.3
        let sunSize = CGSize(
            width: sunDimension,
            height: sunDimension
        )
        let sunPosition = CGPoint(
            x: gameWorld.camera.safeArea.size.width * 0.75,
            y: gameWorld.camera.safeArea.size.height * 0.75,
        )

        let sunNode = SKSpriteNode(imageNamed: "smiling_sun")
        sunNode.size = sunSize
        sunNode.position = sunPosition
        sunNode.zPosition = 0
        sunNode.name = uniqueNodeName

        gameWorld.root[uniqueNodeName].forEach { $0.removeFromParent() }

        gameWorld.root.addChild(sunNode)

        // Animate the sun into the world:

        sunNode.alpha = 0
        sunNode.zRotation = .pi * 2

        let rotateAndFadeIn: SKAction = .sequence([
            .group([
                .rotate(toAngle: 0, duration: 0.5),
                .fadeIn(withDuration: 0.5),
            ]),
            .run {
                completion(sunNode)
            },
        ])

        sunNode.run(rotateAndFadeIn)
    }
}
