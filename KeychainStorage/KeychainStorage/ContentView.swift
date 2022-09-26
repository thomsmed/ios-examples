//
//  ContentView.swift
//  KeychainStorage
//
//  Created by Thomas Asheim Smedmann on 26/09/2022.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Button("Fetch") {
                viewModel.fetch()
            }.padding()

            Button("Persist") {
                viewModel.persist()
            }.padding()

            Button("Delete") {
                viewModel.delete()
            }.padding()

            Text(viewModel.message)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
