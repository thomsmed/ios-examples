//
//  Extractor.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import UIKit

enum Extractor {

    static func urlComponents(from launchOptions: [UIApplication.LaunchOptionsKey : Any]) -> URLComponents? {
        guard let url = launchOptions[.url] as? URL else {
            return nil
        }

        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }

    static func urlComponents(from connectionOptions: UIScene.ConnectionOptions) -> URLComponents? {
        if let userActivity = connectionOptions.userActivities.first {
            return urlComponents(from: userActivity)
        }

        // NOTE:
        // UNUserNotificationCenterDelegate.userNotificationCenter(_:,didReceive:,withCompletionHandler:) Will still be called if you process the notificationResponse
        guard let notificationResponse = connectionOptions.notificationResponse else {
            return nil
        }

        return urlComponents(from: notificationResponse)
    }

    static func urlComponents(from userActivity: NSUserActivity) -> URLComponents? {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        else {
            return nil
        }

        return URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
    }

    static func urlComponents(from pasteboard: UIPasteboard) -> URLComponents? {
        guard
            pasteboard.hasURLs,
            let pasteboardURL = pasteboard.url,
            let _ = pasteboardURL.absoluteString.range(of: "www.flowviewpattern.com", options: .caseInsensitive)
        else {
            return nil
        }

        pasteboard.url = nil

        return URLComponents(url: pasteboardURL, resolvingAgainstBaseURL: true)
    }

    static func urlComponents(from notificationResponse: UNNotificationResponse) -> URLComponents? {
        let userInfo = notificationResponse.notification.request.content.userInfo
        let categoryIdentifier = notificationResponse.notification.request.content.categoryIdentifier

        guard
            categoryIdentifier == "LINK",
            let deepLink = userInfo["link"] as? String,
            let deepLinkUrl = URL(string: deepLink)
        else {
            return nil
        }

        return URLComponents(url: deepLinkUrl, resolvingAgainstBaseURL: true)
    }
}
