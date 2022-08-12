//
//  ExploreFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol ExploreFlowViewFactory: AnyObject {
    func makeMapAndListFlowView(with flowCoordinator: ExploreFlowCoordinator) -> MapAndListFlowView
    func makeExploreNewsView() -> ExploreNewsView
}

extension DefaultAppFlowViewFactory: ExploreFlowViewFactory {
    func makeMapAndListFlowView(with flowCoordinator: ExploreFlowCoordinator) -> MapAndListFlowView {
        MapAndListFlowView()
    }

    func makeExploreNewsView() -> ExploreNewsView {
        ExploreNewsView()
    }
}
