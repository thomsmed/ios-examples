//
//  SceneDelegate.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    weak var appFlowHost: AppFlowHost?

    // MARK: Lifecycle

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let flowHost = appDelegate.appFlowHost.flowHost(for: scene)

        let onboardingComplete = false // TODO: Fetch from settings / UserDefaults
        if onboardingComplete {
            if
                let urlComponents = Extractor.urlComponents(from: connectionOptions),
                let appPage: AppPage = .from(urlComponents),
                case let .primary(primaryPage) = appPage
            {
                flowHost.start(primaryPage)
            } else {
                flowHost.start(.main(page: .explore(page: .store(page: .map(page: nil, storeId: nil)))))
            }
        } else if
            let urlComponents = Extractor.urlComponents(from: UIPasteboard.general),
            let appPage: AppPage = .from(urlComponents),
            case let .primary(primaryPage) = appPage
        {
            flowHost.start(primaryPage)
        } else {
            flowHost.start(.onboarding(page: .home))
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = flowHost
        window.makeKeyAndVisible()

        self.appFlowHost = appDelegate.appFlowHost
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        appFlowHost?.discardFlowHost(for: scene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        appFlowHost?.flowHost(for: scene).sceneDidBecomeActive()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        appFlowHost?.flowHost(for: scene).sceneWillResignActive()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        appFlowHost?.flowHost(for: scene).sceneWillEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        appFlowHost?.flowHost(for: scene).sceneDidEnterBackground()
    }
}

// MARK: Handle user activities (like clicking a Universal Link)

extension SceneDelegate {

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard
            let urlComponents = Extractor.urlComponents(from: userActivity),
            let appPage: AppPage = .from(urlComponents)
        else {
            return
        }

        appFlowHost?.go(to: appPage)
    }
}

// MARK: Handle URLs with custom URL scheme (iOS 13+)

extension SceneDelegate {

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

    }
}
