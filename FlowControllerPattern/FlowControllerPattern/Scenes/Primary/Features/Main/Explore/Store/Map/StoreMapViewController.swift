//
//  StoreMapViewController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 07/07/2022.
//

import UIKit

final class StoreMapViewController: UIViewController {

    private lazy var storeMapView = StoreMapView()

    override func loadView() {
        view = storeMapView
    }

}

// MARK: Public methods

extension StoreMapViewController {

    func selectStore(with storeId: String) {
        
    }
}
