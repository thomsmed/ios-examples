//
//  TabBarController.swift
//  DynamicAnimations
//
//  Created by Thomas Asheim Smedmann on 17/07/2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let attachmentBehaviorViewController = AttachmentBehaviorViewController()
        attachmentBehaviorViewController.title = "Attachment Behavior"
        let attachmentBehaviorNavigationController = UINavigationController(
            rootViewController: attachmentBehaviorViewController
        )
        attachmentBehaviorNavigationController.tabBarItem.title = "Attach"
        attachmentBehaviorNavigationController.tabBarItem.image = UIImage(
            systemName: "figure.climbing"
        )

        let snapBehaviourViewController = SnapBehaviorViewController()
        snapBehaviourViewController.title = "Snap Behavior"
        let snapBehaviourNavigationController = UINavigationController(
            rootViewController: snapBehaviourViewController
        )
        snapBehaviourNavigationController.tabBarItem.title = "Snap"
        snapBehaviourNavigationController.tabBarItem.image = UIImage(
            systemName: "figure.play"
        )

        let collisionBehaviorViewController = CollisionBehaviorViewController()
        collisionBehaviorViewController.title = "Collision Behavior"
        let collisionBehaviorNavigationController = UINavigationController(
            rootViewController: collisionBehaviorViewController
        )
        collisionBehaviorNavigationController.tabBarItem.title = "Collision"
        collisionBehaviorNavigationController.tabBarItem.image = UIImage(
            systemName: "figure.curling"
        )

        let fieldBehaviorViewController = FieldBehaviorViewController()
        fieldBehaviorViewController.title = "Field Behavior"
        let fieldBehaviorNavigationController = UINavigationController(
            rootViewController: fieldBehaviorViewController
        )
        fieldBehaviorNavigationController.tabBarItem.title = "Field"
        fieldBehaviorNavigationController.tabBarItem.image = UIImage(
            systemName: "figure.socialdance"
        )

        let pushBehaviorViewController = PushBehaviorViewController()
        pushBehaviorViewController.title = "Push Behavior"
        let pushBehaviorNavigationController = UINavigationController(
            rootViewController: pushBehaviorViewController
        )
        pushBehaviorNavigationController.tabBarItem.title = "Push"
        pushBehaviorNavigationController.tabBarItem.image = UIImage(
            systemName: "figure.baseball"
        )

        viewControllers = [
            attachmentBehaviorNavigationController,
            snapBehaviourNavigationController,
            collisionBehaviorNavigationController,
            fieldBehaviorNavigationController,
            pushBehaviorNavigationController
        ]
    }
}
