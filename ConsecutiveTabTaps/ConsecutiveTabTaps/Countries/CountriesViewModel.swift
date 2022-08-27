//
//  CountriesViewModel.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import Foundation
import Combine

final class CountriesViewModel: ObservableObject {

    @Published var pageStack: [CountriesView.SubPage] = []
    @Published var countryInFocus: Country? = nil

    var countries: [Country] = []

    private var subscription: AnyCancellable?

    init(consecutiveTaps: AnyPublisher<Void, Never>) {

        NSLocale.isoCountryCodes.forEach { countryCode in
            guard let name = Locale.current.localizedString(
                forRegionCode: countryCode
            ) else {
                return
            }

            countries.append(Country(id: name, emojiFlag: .emojiFlag(for: countryCode)))
        }

        subscription = consecutiveTaps
            .sink { [weak self] in
                guard let self else { return }

                if self.pageStack.isEmpty {
                    self.countryInFocus = self.countries.first
                } else {
                    self.pageStack.removeLast()
                }
            }
    }
}
