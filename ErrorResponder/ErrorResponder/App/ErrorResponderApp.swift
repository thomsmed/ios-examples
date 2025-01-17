//
//  ErrorResponderApp.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

@main
struct ErrorResponderApp: App {
    @State private var errorResponderChain = ErrorResponderChain()
    @State private var backgroundService = BackgroundService()
    @State private var rootViewModel = RootCoordinatorView.ViewModel()

    @State private var errorResponderChainHandle: UUID?

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(viewModel: rootViewModel)
                .onAppear {
                    rootViewModel.parentResponder = errorResponderChain

                    errorResponderChainHandle = errorResponderChain.connect { error in
                        switch error {
                        case BackgroundServiceError.nonCritical:
                            return .proceed

                        case BackgroundServiceError.critical:
                            return .abort

                        default:
                            return nil
                        }
                    }

                    Task {
                        await backgroundService.start(andBindTo: errorResponderChain)
                    }
                }
                .onDisappear {
                    rootViewModel.parentResponder = nil

                    if let errorResponderChainHandle {
                        errorResponderChain.disconnect(errorResponderChainHandle)
                    }

                    Task {
                        await backgroundService.stop()
                    }
                }
        }
    }
}
