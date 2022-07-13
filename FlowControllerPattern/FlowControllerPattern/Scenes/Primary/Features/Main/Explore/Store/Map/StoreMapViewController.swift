//
//  StoreMapViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 07/07/2022.
//

import UIKit

protocol StoreMapViewHolder: UIViewController {
    func selectStore(with storeId: String)
}

final class StoreMapViewController: UIViewController {

    private lazy var storeMapView = StoreMapView()

    override func loadView() {
        view = storeMapView

        view.backgroundColor = .systemBackground
    }

}

// MARK: StoreMapViewHolder

extension StoreMapViewController: StoreMapViewHolder {

    func selectStore(with storeId: String) {
        
    }
}
