//
//  CountryView.swift
//  ConsecutiveTabTaps
//
//  Created by Thomas Asheim Smedmann on 27/08/2022.
//

import SwiftUI

struct CountryView: View {
    var country: Country

    var body: some View {
        ScrollView {
            Text(country.emojiFlag ?? "")
                .font(.system(size: 72))
                .padding(16)
            Text(country.id)
        }
        .navigationTitle(country.id)
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        CountryView(country: .init(id: "Norway", emojiFlag: "🇳🇴"))
    }
}
