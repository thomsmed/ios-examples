//
//  ContentView.swift
//  NetworkMonitoring
//
//  Created by Thomas Asheim Smedmann on 06/11/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Text("Network state history")
                .font(.title)
            List($viewModel.connectionHistory.indices, id: \.self) { historyIndex in
                let connectionStatus = viewModel.connectionHistory[historyIndex]
                VStack {
                    HStack {
                        Text("Summary")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text(connectionStatus.description)
                            .font(.footnote)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    HStack {
                        Text("Available interfaces")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text(connectionStatus.availableInterfaces)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            Spacer()
            Text("Toggle WiFi/Cellular on/off to trigger change in network state")
                .multilineTextAlignment(.center)
                .font(.subheadline)
        }
        .padding()
        .onAppear {
            viewModel.startNetworkMonitor()
        }
        .onDisappear {
            viewModel.cancelNetworkMonitor()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
