//
//  ProfileFlowViewModel.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 13/08/2022.
//

import Foundation

final class ProfileFlowViewModel: ObservableObject {

    @Published var flag: Bool = false
}

extension ProfileFlowViewModel {

    func toggle() {
        flag.toggle() // This triggers a redraw, even if `flag` is not used in ProfileFlowView
    }
}
