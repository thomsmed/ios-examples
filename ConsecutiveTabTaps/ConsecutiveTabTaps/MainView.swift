//
//  MainView.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import SwiftUI

struct MainView: View {

    @StateObject var viewModel: MainViewModel

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            CountriesView(
                viewModel: CountriesViewModel(
                    consecutiveTaps: viewModel.consecutiveTaps(on: .countries)
                )
            )
            .tabItem {
                Label(
                    Tab.countries.title,
                    systemImage: Tab.countries.systemImageName
                )
            }
        }
    }
}

extension MainView {
    enum Tab {
        case countries

        var title: String {
            switch self {
            case .countries:
                return "Countries"
            }
        }

        var systemImageName: String {
            switch self {
            case .countries:
                return "flag"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
