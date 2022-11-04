//
//  BuildConfigurationsApp.swift
//  BuildConfigurations
//
//  Created by Thomas Asheim Smedmann on 04/11/2022.
//

import SwiftUI

@main
struct BuildConfigurationsApp: App {

    static let propertiesDict: [String: String] = {
        guard
            let url = Bundle.main.url(forResource: "Properties", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plistDict = try? PropertyListSerialization.propertyList(
                from: data,
                options: .mutableContainers,
                format: nil
            ),
            let propertiesDisc = plistDict as? [String: String]
        else {
            fatalError()
        }

        return propertiesDisc
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(properties: Self.propertiesDict)
        }
    }
}
