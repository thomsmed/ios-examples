//
//  ConsecutiveTabTapsApp.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import SwiftUI

@main
struct ConsecutiveTabTapsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel())
        }
    }
}
