//
//  Application.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import UIKit

protocol Application: AnyObject {
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: Application { }
