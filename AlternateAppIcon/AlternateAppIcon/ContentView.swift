//
//  ContentView.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack {
                ForEach(viewModel.icons, id: \.appIconName) { icon in
                    HStack {
                        Image(uiImage: UIImage(named: icon.appIconName)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                            .cornerRadius(16)
                            .padding(8)

                        Text(icon.appIconName)
                            .padding(8)

                        Spacer()

                        if icon.selected {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .onTapGesture {
                        viewModel.selectAppIcon(icon.appIconName)
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .navigationTitle("App Icon")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(
            application: MockDependencies.shared.application,
            appInfoProvider: MockDependencies.shared.appInfoProvider
        ))
    }
}
