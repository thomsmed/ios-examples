//
//  AppFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct AppFlowView: View {

    @StateObject var flowViewModel: AppFlowViewModel
    let flowViewFactory: AppFlowViewFactory

    var body: some View {
        if flowViewModel.onboardingComplete {
            flowViewFactory.makeMainFlowView(with: flowViewModel)
        } else {
            flowViewFactory.makeOnboardingFlowView(with: flowViewModel)
        }
    }
}

struct AppFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(
            flowViewModel: .init(
                appDependencies: MockAppDependencies.shared
            ),
            flowViewFactory: MockFlowViewFactory.shared
        )
    }
}
