//
//  Tab.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import Foundation

enum Tab {
    case explore
    case activity
    case profile

    var title: String {
        switch self {
        case .explore:
            return "Explore"
        case .activity:
            return "Activity"
        case .profile:
            return "Profile"
        }
    }

    var systemImageName: String {
        switch self {
        case .explore:
            return "map"
        case .activity:
            return "star"
        case .profile:
            return "person"
        }
    }
}
