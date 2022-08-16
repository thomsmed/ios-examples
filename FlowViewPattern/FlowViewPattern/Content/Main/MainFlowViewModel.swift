//
//  MainFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI
import Combine

final class MainFlowViewModel: ObservableObject {

    @Published var selectedTab: MainFlowView.Tab = .explore
    @Published var presentedSheet: MainFlowView.Sheet = .none
    @Published var toggleSheet: Bool = false

    private weak var flowCoordinator: AppFlowCoordinator?
    private let appDependencies: AppDependencies

    init(
        flowCoordinator: AppFlowCoordinator,
        appDependencies: AppDependencies,
        initialPath: AppPath.Main?
    ) {
        self.flowCoordinator = flowCoordinator
        self.appDependencies = appDependencies

        switch initialPath {
        case let .explore(subPath):
            selectedTab = .explore
        case let .activity(subPath):
            selectedTab = .activity
        case let .profile(subPath):
            selectedTab = .profile
        case let .booking(subPath, storeId):
            selectedTab = .explore
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.presentedSheet = .booking
                self?.toggleSheet.toggle()
            }
        default:
            selectedTab = .explore

            let longTimeNoSee = true
            if longTimeNoSee {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.presentedSheet = .greeting
                    self?.toggleSheet.toggle()
                }
            }
        }
    }

    func go(to path: AppPath.Main) {
        switch path {
        case let .explore(subPath):
            selectedTab = .explore
        case let .activity(subPath):
            selectedTab = .activity
        case let .profile(subPath):
            selectedTab = .profile
        case let .booking(subPath, storeId):
            selectedTab = .explore
            presentedSheet = .booking
            toggleSheet.toggle()
        }
    }
}

extension MainFlowViewModel: MainFlowCoordinator {

    func presentBooking() {
        presentedSheet = .booking
        toggleSheet.toggle()
    }
}
