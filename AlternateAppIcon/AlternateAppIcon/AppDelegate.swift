//
//  AppDelegate.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    private(set) lazy var dependencies = DefaultDependencies()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        return true
    }
}
