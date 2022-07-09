//
//  Extractor.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 08/07/2022.
//

import UIKit

final class Extractor {

    static func urlComponents(from connectionOptions: UIScene.ConnectionOptions) -> URLComponents? {
        guard let userActivity = connectionOptions.userActivities.first else {
            return nil
        }

        return urlComponents(from: userActivity)
    }

    static func urlComponents(from userActivity: NSUserActivity) -> URLComponents? {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        else {
            return nil
        }

        return components
    }
}
