//
//  AppPage.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
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
    enum Onboarding: PathRepresentable {
        case home
    }

    enum Main: PathRepresentable {
        enum Explore: PathRepresentable {
            enum Store: PathRepresentable {
                case map(page: Booking? = nil, storeId: String? = nil)
                case list
            }

            case store(page: Store)
            case referral
        }

        enum Activity: PathRepresentable {
            enum Purchases: PathRepresentable {
                case active
                case history
            }

            case purchases(page: Purchases)
        }

        enum Profile: PathRepresentable {
            case home
            case edit
        }

        enum Booking: PathRepresentable {
            struct Details: Equatable {
                let services: [String]
                let products: [String]
            }

            case home(details: Details)
            case checkout(details: Details)
        }

        case explore(page: Explore)
        case activity(page: Activity)
        case profile(page: Profile)
        case booking(page: Booking, storeId: String, details: Booking.Details?)
    }

    case onboarding(page: Onboarding)
    case main(page: Main)
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
        // ".../app/main/explore/store/map/{storeId}/booking/checkout?service={service}&product={product}"
        // ".../app/main/booking/checkout?service={service}&product={product}"

        return .from(.init(pathComponents.dropFirst()), and: queryItems)
    }

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage {
        guard let pathComponent = pathComponents.first else {
            return .main(page: .explore(page: .store(page: .map(page: nil, storeId: nil))))
        }

        if pathComponent.isCaseInsensitiveEqual(to: "onboarding") {
            return .onboarding(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
        }

        return .main(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
    }
}

extension AppPage.Onboarding {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Onboarding {
        .home
    }
}

extension AppPage.Main {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main {
        guard let pathComponent = pathComponents.first else {
            return .explore(page: .store(page: .map(page: nil, storeId: nil)))
        }

        if pathComponent.isCaseInsensitiveEqual(to: "explore") {
            return .explore(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "activity") {
            return .activity(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "profile") {
            return .profile(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "booking") {
            let morePathComponents: [String] = .init(pathComponents.dropFirst())
            guard let storeId = morePathComponents.first else {
                return .explore(page: .store(page: .map(page: nil, storeId: nil)))
            }
            return .booking(page: .from(.init(pathComponents.dropFirst()), and: queryItems), storeId: storeId, details: nil)
        }

        return .explore(page: .store(page: .map(page: nil, storeId: nil)))
    }
}

extension AppPage.Main.Explore {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Explore {
        guard let pathComponent = pathComponents.first else {
            return .store(page: .map(page: nil, storeId: nil))
        }

        if pathComponent.isCaseInsensitiveEqual(to: "referral") {
            return .referral
        }

        return .store(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
    }
}

extension AppPage.Main.Explore.Store {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Explore.Store {
        guard let pathComponent = pathComponents.first else {
            return .map(page: nil, storeId: nil)
        }

        if pathComponent.isCaseInsensitiveEqual(to: "list") {
            return .list
        }

        guard
            pathComponents.count > 2,
            pathComponents[1].isCaseInsensitiveEqual(to: "booking")
        else {
            return .map(page: nil, storeId: nil)
        }

        return .map(page: .from(.init(pathComponents.dropFirst(3)), and: queryItems), storeId: pathComponents[2])
    }
}

extension AppPage.Main.Activity {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Activity {
        if pathComponents.isEmpty {
            return .purchases(page: .history)
        }

        return .purchases(page: .from(.init(pathComponents.dropFirst()), and: queryItems))
    }
}

extension AppPage.Main.Activity.Purchases {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Activity.Purchases {
        guard let pathComponent = pathComponents.first else {
            return .history
        }

        if pathComponent.isCaseInsensitiveEqual(to: "active"){
            return .active
        }

        return .history
    }
}

extension AppPage.Main.Profile {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Profile {
        guard let pathComponent = pathComponents.first else {
            return .home
        }

        if pathComponent.isCaseInsensitiveEqual(to: "edit") {
            return .edit
        }

        return .home
    }
}

extension AppPage.Main.Booking {

    static func from(_ pathComponents: [String], and queryItems: [URLQueryItem]) -> AppPage.Main.Booking {
        guard let pathComponent = pathComponents.first else {
            return .home(details: .init(services: [], products: []))
        }

        var services: [String] = []
        var products: [String] = []
        queryItems.forEach { queryItem in
            if queryItem.name == "service", let value = queryItem.value {
                services.append(value)
            } else if queryItem.name == "product", let value = queryItem.value {
                products.append(value)
            }
        }

        if pathComponent.isCaseInsensitiveEqual(to: "checkout") {
            return .checkout(details: .init(services: services, products: products))
        }

        return .home(details: .init(services: services, products: products))
    }
}
