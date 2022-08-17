//
//  AppFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct AppFlowView: View {

    @ObservedObject var flowViewModel: AppFlowViewModel
    let flowViewFactory: AppFlowViewFactory

    var body: some View {
        ZStack {
            switch flowViewModel.selectedPage {
            case .onboarding:
                flowViewFactory.makeOnboardingFlowView(
                    with: flowViewModel
                )
            case let .main(subPath):
                flowViewFactory.makeMainFlowView(
                    with: flowViewModel,
                    startingAt: subPath
                )
            }
        }
        .onOpenURL { url in
            guard let path = AppPath(url) else {
                return
            }

            flowViewModel.go(to: path)
        }
    }
}

extension AppFlowView {
    enum Page {
        case onboarding
        case main(AppPath.Main? = nil)
    }
}

extension AppPath {
    init?(_ url: URL) {
        guard let urlComponents = URLComponents(
            url: url, resolvingAgainstBaseURL: true
        ) else {
            return nil
        }

        self.init(urlComponents)
    }
}

struct AppFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(
            flowViewModel: .init(
                appDependencies: PreviewAppDependencies.shared
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
