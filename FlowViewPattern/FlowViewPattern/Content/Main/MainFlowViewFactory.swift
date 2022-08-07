//
//  MainFlowViewFactory.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import Foundation

protocol MainFlowViewFactory: AnyObject {
    func makeExploreFlowView() -> ExploreFlowView
    func makeActivityFlowView() -> ActivityFlowView
    func makeProfileFlowView() -> ProfileFlowView
    func makeBookingFlowView() -> BookingFlowView
}
