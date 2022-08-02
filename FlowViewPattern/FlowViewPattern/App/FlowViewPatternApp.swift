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

    init() {
        // One time initialization etc...
    }

    var body: some Scene {
        WindowGroup {
            AppFlowView(
                flowViewModel: .init(
                    appDependencies: appDependencies
                )
            )
        }
    }
}
