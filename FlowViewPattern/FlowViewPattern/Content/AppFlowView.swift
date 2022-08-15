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
            case .main:
                flowViewFactory.makeMainFlowView(
                    with: flowViewModel
                )
            }
        }
    }
}

extension AppFlowView {
    enum Page {
        case onboarding
        case main
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
