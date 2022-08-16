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
                // NOTE: This view modifier can be applied to all views in the hierarchy.
                // So that might be an alternative to propagating deep links down the view hierarchy (apply this modifier to FlowViews):
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
