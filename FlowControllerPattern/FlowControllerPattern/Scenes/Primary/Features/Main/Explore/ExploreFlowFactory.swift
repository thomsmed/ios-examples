//
//  ExploreFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol ExploreFlowFactory: AnyObject {
    func makeStoreFlowHost(with flowController: ExploreFlowController) -> StoreFlowHost
    func makeReferralViewHolder() -> ReferralViewHolder
}

extension DefaultAppFlowFactory: ExploreFlowFactory {

    func makeStoreFlowHost(with flowController: ExploreFlowController) -> StoreFlowHost {
        DefaultStoreFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    func makeReferralViewHolder() -> ReferralViewHolder {
        ReferralViewController()
    }
}
