//
//  MainFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct MainFlowView: View {

    @StateObject var flowViewModel: MainFlowViewModel

    @AppStorage("show") var show: Bool = false

    var body: some View {
        VStack {
            Text("Main flow")
            Button("Continue") {
                show = false
            }
        }
    }
}

struct MainFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MainFlowView(
            flowViewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared,
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
