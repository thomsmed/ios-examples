//
//  SettingsCoordinatorView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct SettingsCoordinatorView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Misc") {
                    Toggle(isOn: .constant(true)) {
                        Text("Always on")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
