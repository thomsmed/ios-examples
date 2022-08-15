//
//  FlowViewPatternApp.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

@main
struct FlowViewPatternApp: App {

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            AppFlowView(
                flowViewModel: appDelegate.appFlowCoordinator,
                flowViewFactory: appDelegate.appFlowViewFactory
            )
            .onOpenURL { url in
                guard
                    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                    let page: AppPage = .from(urlComponents)
                else {
                    return
                }

                appDelegate.appFlowCoordinator.go(to: page)
            }
        }
    }
}
