//
//  AppFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct AppFlowView: View {

    @StateObject var flowViewModel: AppFlowViewModel

    @AppStorage("show") var show: Bool = false

    var body: some View {
        if show {
            flowViewModel.makeMainFlowView()
        } else {
            flowViewModel.makeOnboardingFlowView()
        }
    }
}

struct AppFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(
            flowViewModel: .init(
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
