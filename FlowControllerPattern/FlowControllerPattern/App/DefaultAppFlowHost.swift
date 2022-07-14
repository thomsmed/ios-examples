//
//  DefaultAppFlowHost.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

final class DefaultAppFlowHost: NSObject {

    private let flowFactory: AppFlowFactory

    private var flowHostsByScene: [UIScene: PrimarySceneFlowHost] = [:]

    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    init(flowFactory: AppFlowFactory) {
        self.flowFactory = flowFactory
    }
}

extension DefaultAppFlowHost: AppFlowHost {

    func applicationDidFinishLaunchingWith(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions

        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound, .provisional]
        ) { success, error in

        }
    }

    func flowHost(for scene: UIScene) -> PrimarySceneFlowHost {
        if let flowHost = flowHostsByScene[scene] {
            return flowHost
        }

        let flowHost = flowFactory.makePrimarySceneFlowHost(with: self)

        flowHostsByScene[scene] = flowHost

        return flowHost
    }

    func discardFlowHost(for scene: UIScene) {
        flowHostsByScene[scene] = nil
    }
}


// MARK: UNUserNotificationCenterDelegate

extension DefaultAppFlowHost: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        let categoryIdentifier = notification.request.content.categoryIdentifier

        if categoryIdentifier == "LINK" {
            completionHandler([.banner, .sound])
        } else {
            print(userInfo)
            completionHandler([])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier

        switch response.actionIdentifier {
        case "com.thomsmed.UNNotificationCustomActionIdentifier":
            print(userInfo)
        case UNNotificationDefaultActionIdentifier:
            if let urlComponents = Extractor.urlComponents(from: response) {
                flowHostsByScene.first?.value.go(to: .from(urlComponents))
            } else {
                print(categoryIdentifier)
            }
        case UNNotificationDismissActionIdentifier:
            break
        default:
            break
        }

        completionHandler()
    }
}
