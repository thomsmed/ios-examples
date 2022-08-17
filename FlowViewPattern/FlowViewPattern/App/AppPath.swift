//
//  AppPath.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 12/08/2022.
//

import Foundation

protocol PathRepresentable: Equatable {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem])
}

extension String {
    func isCaseInsensitiveEqual(to otherString: String) -> Bool {
        range(of: otherString, options: .caseInsensitive) != nil
    }
}

enum AppPath: PathRepresentable {
    enum Onboarding: PathRepresentable {
        case welcome
    }

    enum Main: PathRepresentable {
        enum Explore: PathRepresentable {
            enum Store: PathRepresentable {
                case map(Booking? = nil, storeId: String? = nil)
                case list
            }

            case store(Store)
            case news
        }

        enum Activity: PathRepresentable {
            enum Purchases: PathRepresentable {
                case active
                case history
            }

            case purchases(Purchases)
        }

        enum Profile: PathRepresentable {
            case persona
            case edit
        }

        enum Booking: PathRepresentable {
            struct Details: Equatable {
                let services: [String]
                let products: [String]
            }

            case store(details: Details?)
            case checkout(details: Details?)
        }

        case explore(Explore)
        case activity(Activity)
        case profile(Profile)
        case booking(Booking, storeId: String)
    }

    case onboarding(Onboarding)
    case main(Main)
}

extension AppPath {
    init?(_ urlComponents: URLComponents) {
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

        self = .init(.init(pathComponents.dropFirst()), and: queryItems)
    }

    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .main(.explore(.store(.map(nil, storeId: nil))))
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "onboarding") {
            self = .onboarding(.init(.init(pathComponents.dropFirst()), and: queryItems))
        } else {
            self = .main(.init(.init(pathComponents.dropFirst()), and: queryItems))
        }
    }
}

extension AppPath.Onboarding {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        self = .welcome
    }
}

extension AppPath.Main {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .explore(.store(.map(nil, storeId: nil)))
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "explore") {
            self = .explore(.init(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "activity") {
            self = .activity(.init(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "profile") {
            self = .profile(.init(.init(pathComponents.dropFirst()), and: queryItems))
        } else if pathComponent.isCaseInsensitiveEqual(to: "booking") {
            let morePathComponents: [String] = .init(pathComponents.dropFirst())
            guard let storeId = morePathComponents.first else {
                self = .explore(.store(.map(nil, storeId: nil)))
                return
            }
            self = .booking(.init(.init(pathComponents.dropFirst()), and: queryItems), storeId: storeId)
        } else {
            self = .explore(.store(.map(nil, storeId: nil)))
        }
    }
}

extension AppPath.Main.Explore {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .store(.map(nil, storeId: nil))
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "news") {
            self = .news
        } else {
            self = .store(.init(.init(pathComponents.dropFirst()), and: queryItems))
        }
    }
}

extension AppPath.Main.Explore.Store {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .map(nil, storeId: nil)
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "list") {
            self = .list
            return
        }

        guard pathComponent.count > 1 else {
            self = .map(nil, storeId: nil)
            return
        }

        guard
            pathComponents.count > 2,
            pathComponents[2].isCaseInsensitiveEqual(to: "booking")
        else {
            self = .map(nil, storeId: pathComponents[1])
            return
        }

        self = .map(.init(.init(pathComponents.dropFirst(3)), and: queryItems), storeId: pathComponents[1])
    }
}

extension AppPath.Main.Activity {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        if pathComponents.isEmpty {
            self = .purchases(.history)
        } else {
            self = .purchases(.init(.init(pathComponents.dropFirst()), and: queryItems))
        }
    }
}

extension AppPath.Main.Activity.Purchases {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .history
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "active"){
            self = .active
        } else {
            self = .history
        }
    }
}

extension AppPath.Main.Profile {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .persona
            return
        }

        if pathComponent.isCaseInsensitiveEqual(to: "edit") {
            self = .edit
        } else {
            self = .persona
        }
    }
}

extension AppPath.Main.Booking {
    init(_ pathComponents: [String], and queryItems: [URLQueryItem]) {
        guard let pathComponent = pathComponents.first else {
            self = .store(details: .init(services: [], products: []))
            return
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
            self = .checkout(details: .init(services: services, products: products))
        } else {
            self = .store(details: .init(services: services, products: products))
        }
    }
}
