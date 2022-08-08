//
//  ExploreFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol ExploreFlowViewFactory: AnyObject {
    func makeMapAndListFlowView() -> MapAndListFlowView
    func makeExploreNewsView() -> ExploreNewsView
}
