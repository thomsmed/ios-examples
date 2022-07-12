//
//  AppFlowFactory.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 13/07/2022.
//

import Foundation

protocol AppFlowFactory: AnyObject {
    func makePrimarySceneFlowHost(with flowController: AppFlowController) -> PrimarySceneFlowHost
}
