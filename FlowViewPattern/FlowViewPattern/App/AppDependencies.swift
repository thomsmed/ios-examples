//
//  AppDependencies.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import Foundation

protocol AppDependencies: AnyObject {
    var defaultsRepository: DefaultsRepository { get }
}
