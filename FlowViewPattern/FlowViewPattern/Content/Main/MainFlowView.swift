//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var viewModel: MainFlowViewModel

    var body: some View {
        Text("Main flow")
    }
}

struct MainFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MainFlowView(
            viewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
