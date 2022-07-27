//
//  StoreFilterSheetController.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import UIKit

protocol StoreFilterSheetHolder: UIViewController {

}

final class StoreFilterSheetController: UIViewController {

    var onSelect: (StoreFlow.FilterOptions) -> Void = { _ in }
}

extension StoreFilterSheetController: StoreFilterSheetHolder {
    
}
