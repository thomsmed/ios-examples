//
//  AppDelegate.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    // NOTE: Let AppDelegate conform to ObservableObject if you need to have access to the delegate as an EnvironmentObject

    private(set) lazy var appDependencies = DefaultAppDependencies()
    private(set) lazy var appFlowCoordinator = AppFlowViewModel(appDependencies: appDependencies)
    private(set) lazy var appFlowViewFactory = DefaultAppFlowViewFactory(appDependencies: appDependencies)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Do initial stuff, like register for remote notifications or initialising third party libraries etc

        application.registerForRemoteNotifications()

        guard appDependencies.defaultsRepository.date(for: .firstAppLaunch) == nil else {
            return true
        }

        appDependencies.defaultsRepository.set(Date.now, for: .firstAppLaunch)

        return true
    }
}

// MARK: Remote notifications

extension AppDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("didFailToRegisterForRemoteNotificationsWithError")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) async -> UIBackgroundFetchResult {
        return .noData
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

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
            print(categoryIdentifier)

            guard
                let urlComponents = Extractor.urlComponents(from: response),
                let path = AppPath(urlComponents)
            else {
                break
            }

            appFlowCoordinator.go(to: path)
        case UNNotificationDismissActionIdentifier:
            break
        default:
            break
        }

        completionHandler()
    }
}
