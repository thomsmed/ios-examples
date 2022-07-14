//
//  AppPage.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 14/07/2022.
//

import Foundation

protocol PathRepresentable: Equatable {
    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> Self
}

extension String {

    func isCaseInsensitiveEqual(to otherString: String) -> Bool {
        range(of: otherString, options: .caseInsensitive) != nil
    }
}

enum AppPage: PathRepresentable {
    case primary(page: AppPage.Primary)
}

extension AppPage {

    static func from(_ urlComponents: URLComponents) -> AppPage? {
        let path = urlComponents.path
        let queryItems = urlComponents.queryItems ?? []
        let pathComponents = path.components(separatedBy: "/")

        guard
            let pathComponent = pathComponents.first,
            pathComponent.isCaseInsensitiveEqual(to: "app")
        else {
            return nil
        }

        // Example paths:
        // ".../app/primary/main/explore/store/map/{storeId}/booking/checkout?service={service}&product={product}"
        // ".../app/primary/main/booking/checkout?service={service}&product={product}"

        return .from(.init(pathComponents.dropFirst()), and: queryItems)
    }

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage {
        guard let pathComponent = pathComponents.first else {
            return .primary(page: .main(page: .explore(page: .store(page: .map(page: nil, storeId: nil)))))
        }

        if pathComponent.isCaseInsensitiveEqual(to: "primary") {
            return .primary(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
        }

        return .primary(page: .main(page: .explore(page: .store(page: .map(page: nil, storeId: nil)))))
    }
}
