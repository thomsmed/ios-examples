//
//  MapAndListFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol MapAndListFlowViewFactory: AnyObject {
    func makeExploreMapView() -> ExploreMapView
    func makeExploreListView() -> ExploreListView
}
