//
//  ContentView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootCoordinatorView(
            viewModel: RootCoordinatorView.ViewModel { _ in }
        )
    }
}

#Preview {
    ContentView()
}
