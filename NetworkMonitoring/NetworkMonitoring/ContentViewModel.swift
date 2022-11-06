//
//  ContentViewModel.swift
//  NetworkMonitoring
//
//  Created by Thomas Asheim Smedmann on 06/11/2022.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {

    struct ConnectionState {
        let description: String
        let availableInterfaces: String
    }

    private let networkMonitor = NetworkMonitor()

    private var sub: AnyCancellable?

    @Published var connectionHistory: [ConnectionState] = []

    init() {
        sub = networkMonitor.$state
            .compactMap { $0 }
            .sink(receiveValue: { state in
                self.connectionHistory.append(.init(
                    description: state.description,
                    availableInterfaces: state.availableInterfaces.joined(separator: ", ")
                ))
            })
    }

    func startNetworkMonitor() {
        networkMonitor.start()
    }

    func cancelNetworkMonitor() {
        networkMonitor.cancel()
    }
}
