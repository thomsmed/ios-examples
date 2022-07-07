//
//  PrimaryScenePage.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import Foundation

enum PrimaryScenePage {
    enum Onboarding {
        case home
    }

    enum Main {
        enum Explore {
            enum Store {
                case map(page: Booking? = nil, storeId: String? = nil)
                case list
            }

            case store(page: Store)
            case referral
        }

        enum Activity {
            enum Purchases {
                case active
                case history
            }

            case purchases(page: Purchases)
        }

        enum Profile {
            case home
            case edit
        }

        enum Booking {
            struct Details {
                let services: [String]
                let products: [String]
            }

            case home(details: Details)
            case checkout(details: Details)
        }

        case explore(page: Explore)
        case activity(page: Activity)
        case profile(page: Profile)
        case booking(page: Booking, storeId: String, info: StoreInfo? = nil)
    }

    case onboarding(page: Onboarding)
    case main(page: Main)
}
