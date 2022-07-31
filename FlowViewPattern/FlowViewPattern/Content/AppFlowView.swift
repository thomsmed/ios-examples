//
//  AppFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct AppFlowView: View {

    @StateObject var viewModel: AppFlowViewModel

    var body: some View {
        Text("App flow")
    }
}

struct AppFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView(
            viewModel: .init(
                appDependencies: DummyAppDependencies.shared
            )
        )
    }
}
