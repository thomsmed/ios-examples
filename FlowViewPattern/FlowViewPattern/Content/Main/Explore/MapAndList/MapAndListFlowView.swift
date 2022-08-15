//
//  MapAndListFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import SwiftUI

struct MapAndListFlowView: View {

    @StateObject var flowViewModel: MapAndListFlowViewModel
    let flowViewFactory: MapAndListFlowViewFactory

    var body: some View {
        switch flowViewModel.selectedPage {
        case .map:
            flowViewFactory.makeExploreMapView(
                with: flowViewModel
            )
        case .list:
            flowViewFactory.makeExploreListView(
                with: flowViewModel
            )
        }
    }
}

extension MapAndListFlowView {
    enum Page {
        case map
        case list
    }
}

struct MapAndListFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MapAndListFlowView(
            flowViewModel: .init(
                flowCoordinator: PreviewFlowCoordinator.shared
            ),
            flowViewFactory: PreviewFlowViewFactory.shared
        )
    }
}
