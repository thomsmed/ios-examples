//
//  MapAndListFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol MapAndListFlowViewFactory: AnyObject {
    func makeExploreMapView(with flowCoordinator: MapAndListFlowCoordinator) -> ExploreMapView
    func makeExploreListView(with flowCoordinator: MapAndListFlowCoordinator) -> ExploreListView
}

extension DefaultAppFlowViewFactory: MapAndListFlowViewFactory {
    func makeExploreMapView(with flowCoordinator: MapAndListFlowCoordinator) -> ExploreMapView {
        ExploreMapView(viewModel: .init(flowCoordinator: flowCoordinator))
    }

    func makeExploreListView(with flowCoordinator: MapAndListFlowCoordinator) -> ExploreListView {
        ExploreListView(viewModel: .init(flowCoordinator: flowCoordinator))
    }
}
