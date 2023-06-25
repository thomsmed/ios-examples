//
//  AlternateAppIconApp.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import SwiftUI

@main
struct AlternateAppIconApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(
                application: appDelegate.dependencies.application,
                appInfoProvider: appDelegate.dependencies.appInfoProvider
            ))
        }
    }
}
