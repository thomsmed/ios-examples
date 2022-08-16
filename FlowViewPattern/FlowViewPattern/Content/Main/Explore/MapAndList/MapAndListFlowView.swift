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
        ZStack {
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
        .onOpenURL { url in
            guard let path = AppPath.Main.Explore.Store(url) else {
                return
            }

            flowViewModel.go(to: path)
        }
    }
}

extension MapAndListFlowView {
    enum Page {
        case map
        case list
    }
}

extension AppPath.Main.Explore.Store {
    init?(_ url: URL) {
        guard
            let explorePath = AppPath.Main.Explore(url),
            case let .store(subPath) = explorePath
        else {
            return nil
        }

        self = subPath
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
