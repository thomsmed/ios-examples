//
//  ExploreFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreFlowView: View {

    @StateObject var viewModel: ExploreFlowViewModel

    var body: some View {
        Text("Explore flow")
    }
}

struct ExploreFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreFlowView(
            viewModel: .init(
                flowCoordinator: DummyFlowCoordinator.shared
            )
        )
    }
}
