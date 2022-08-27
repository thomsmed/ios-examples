//
//  CountriesView.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import SwiftUI
import Combine

struct CountriesView: View {

    @StateObject var viewModel: CountriesViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            ScrollViewReader { proxy in
                List(viewModel.countries) { country in
                    NavigationLink(
                        country.id,
                        value: SubPage.details(for: country)
                    )
                    .id(country.id)
                }
                .onReceive(viewModel.$countryInFocus) { country in
                    guard let country else { return }

                    withAnimation {
                        proxy.scrollTo(country.id)
                    }
                }
            }
            .navigationTitle("Countries")
            .navigationDestination(for: SubPage.self) { page in
                switch page {
                case let .details(country):
                    CountryView(country: country)
                }
            }
        }
    }
}

extension CountriesView {
    enum SubPage: Hashable {
        case details(for: Country)
    }
}

struct TabOneView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView(viewModel: .init(consecutiveTaps: Empty().eraseToAnyPublisher()))
    }
}
