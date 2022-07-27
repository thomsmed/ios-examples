//
//  StoreFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol StoreFlowFactory: AnyObject {
    func makeStoreMapViewHolder() -> StoreMapViewHolder
    func makeStoreListViewHolder(with flowController: StoreFlowController) -> StoreListViewHolder
    func makeStoreFilterSheetHolder(
        passing completion: @escaping (StoreFlow.FilterOptions) -> Void
    ) -> StoreFilterSheetHolder
}

extension DefaultAppFlowFactory: StoreFlowFactory {

    func makeStoreMapViewHolder() -> StoreMapViewHolder {
        StoreMapViewController()
    }

    func makeStoreListViewHolder(with flowController: StoreFlowController) -> StoreListViewHolder {
        StoreListViewController(viewModel: .init(flowController: flowController))
    }

    func makeStoreFilterSheetHolder(
        passing completion: @escaping (StoreFlow.FilterOptions) -> Void
    ) -> StoreFilterSheetHolder {
        let storeListFilterSheetHolder = StoreFilterSheetController()
        storeListFilterSheetHolder.onSelect = completion
        return storeListFilterSheetHolder
    }
}
