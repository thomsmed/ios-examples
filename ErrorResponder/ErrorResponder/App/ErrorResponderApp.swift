//
//  ErrorResponderApp.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

@main
struct ErrorResponderApp: App {
    @State private var rootViewModel = RootCoordinatorView.ViewModel()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(viewModel: rootViewModel)
        }
    }
}
