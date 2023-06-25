//
//  ContentView+ViewModel.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import Foundation

extension ContentView {
    struct AppIconCellModel {
        let appIconName: String
        let selected: Bool
    }

    final class ViewModel: ObservableObject {
        private let application: Application
        private let appInfoProvider: AppInfoProvider

        private var currentlySelectedIconName: String

        @Published var icons: [AppIconCellModel] = []

        init(application: Application, appInfoProvider: AppInfoProvider) {
            self.application = application
            self.appInfoProvider = appInfoProvider

            currentlySelectedIconName = application.alternateIconName ?? appInfoProvider.primaryAppIconName

            rePopulateIcons()
        }

        private func rePopulateIcons() {
            var icons = appInfoProvider.alternateAppIconNames.map { appIconName in
                AppIconCellModel(
                    appIconName: appIconName,
                    selected: appIconName == currentlySelectedIconName
                )
            }
            icons.append(
                AppIconCellModel(
                    appIconName: appInfoProvider.primaryAppIconName,
                    selected: appInfoProvider.primaryAppIconName == currentlySelectedIconName
                )
            )
            icons.sort(by: { l, r in l.appIconName > r.appIconName })

            self.icons = icons
        }

        func selectAppIcon(_ appIconName: String) {
            guard appIconName != currentlySelectedIconName else {
                return
            }

            currentlySelectedIconName = appIconName

            rePopulateIcons()

            // Nil == no alternate icon selected (the system will then use the primary app icon).
            let alternateIconName = appIconName == appInfoProvider.primaryAppIconName
                ? nil
                : appIconName

            application.setAlternateIconName(alternateIconName) { error in
                if let error {
                    assertionFailure("Somehow failed to set alternate icon name. Error: \(error)")
                }
            }
        }
    }
}
