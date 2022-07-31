//
//  FlowViewPatternApp.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

@main
struct FlowViewPatternApp: App {

    @StateObject var appDependencies = DefaultAppDependencies()

    var body: some Scene {
        WindowGroup {
            AppFlowView(
                viewModel: .init(
                    appDependencies: appDependencies
                )
            )
        }
    }
}
