//
//  MapAndListFlowCoordinator.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol MapAndListFlowCoordinator: AnyObject {
    func showMap()
    func showList()
}

extension MockFlowCoordinator: MapAndListFlowCoordinator {

    func showMap() {

    }

    func showList() {
        
    }
}
