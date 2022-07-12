//
//  StoreFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol StoreFlowFactory: AnyObject {
    func makeStoreMapViewHolder() -> StoreMapViewHolder
    func makeStoreListViewHolder() -> StoreListViewHolder
}

extension DefaultAppFlowFactory: StoreFlowFactory {

    func makeStoreMapViewHolder() -> StoreMapViewHolder {
        StoreMapViewController()
    }

    func makeStoreListViewHolder() -> StoreListViewHolder {
        StoreListViewController()
    }
}
