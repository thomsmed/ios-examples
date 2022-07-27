//
//  StoreListViewModel.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation
import Combine

final class StoreListViewModel {

    enum State {
        case idle
        case loading
        case ready
        case error
    }

    private weak var flowController: StoreFlowController?

    private let stateSubject = CurrentValueSubject<State, Never>(.idle)

    init(flowController: StoreFlowController) {
        self.flowController = flowController
    }
}

// MARK: Public methods

extension StoreListViewModel {

    var state: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func selectStoreFilterOptions() {
        flowController?.selectStoreFilterOptions { [weak self] filterOptions in
            self?.stateSubject.send(.loading)
            // Use filter options to update store list
            DispatchQueue.main.async {
                self?.stateSubject.send(.ready)
            }
        }
    }
}
