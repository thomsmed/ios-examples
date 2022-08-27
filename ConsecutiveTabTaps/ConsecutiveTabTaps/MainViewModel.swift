//
//  MainViewModel.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {

    @Published var selectedTab: MainView.Tab = .countries
}

extension MainViewModel {
    // Inspired by: https://gist.github.com/fxm90/be62335d987016c84d2f8b3731197c98
    typealias PairwiseTabs = (previous: MainView.Tab?, current: MainView.Tab)

    func consecutiveTaps(on tab: MainView.Tab) -> AnyPublisher<Void, Never> {
        $selectedTab
            .scan(PairwiseTabs(previous: nil, current: selectedTab)) { previousPair, current in
                PairwiseTabs(previous: previousPair.current, current: current)
            }
            .filter { $0.previous == $0.current}
            .compactMap { $0.current == tab ? Void() : nil}
            .eraseToAnyPublisher()
    }
}
