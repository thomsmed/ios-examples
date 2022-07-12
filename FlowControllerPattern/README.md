# Flow Controller Pattern
An app navigation pattern

## AppPage, FlowController and FlowHost

AppPage
```swift
// Defining all app-pages that can be deep linked to (via e.g. Universal Links),
// or pages the user can jump into with one click (e.g jumping from Profile to ShoppingCart under the Booking flow)
// Thought of as representing an URL, e.g.: https://www.myapp.com/app/main/booking/{storeId}/checkout?service=123&product=123
enum AppPage {
    enum Main {
        enum Booking: {
            struct Details {
                let services: [String]
                let products: [String]
            }
            
            case store
            case shoppingCart
            case checkout
        }
        
        case home
        case activities
        case profile
        case booking(page: Booking, storeId: String, details: Booking.Details?)
    }

    case onboarding
    case main
}
```

FlowController and FlowHost protocols
```swift
// Known to ViewModels and child FlowHosts
protocol MainFlowController: AnyObject {
    // Where to go next? Where to start after that?
    func continueToBooking(startAt bookingPage: AppPage.Main.Booking)
    // What just happened? Where to go next?
    func bookingComplete(continueTo page: AppPage.Main)
}

// Known to parent FlowHosts
protocol MainFlowHost: FlowController & UIViewController {
    // Start default flow
    func start(_ page: AppPage.Main)
    // Change flow
    func go(to page: AppPage.Main)
}
```

FlowController and FlowHost implementation
```swift
final class DefaultMainFlowHost: UITabBarController {

    private var homeFlowHost: HomeFlowHost?
    private var activitiesFlowHost: ActivitiesFlowHost?
    private var profileFlowHost: ProfileFlowHost?
    
    // ...
    
}

extension DefaultMainFlowHost: MainFlowHost {
    // MARK: MainFlowHost
    
    func start(_ page: AppPage.Main) {
        let homeFlowHost = DefaultHomeFlowHost(...)
        
        // ...
        
        swift page {
            case .home:
                homeFlowHost.start()
                selectedIndex = 0
            
            // ...
            
        }
        
        // ...
        
        self.homeFlowHost = homeFlowHost
        
        // ...
        
    }
    
    func go(to page: AppPage.Main) {
        guard viewControllers?.isEmpty == false else {
            return start(page)
        }
        
        switch page {
            case .home:
                selectedIndex = 0
            
            // ...
            
            case let .booking(bookingPage, storeId, details):
                dismiss(animated: false) {
                    let bookingFlowHost = DefaultBookingFlowHost(...)
                    bookingFlowHost.start(bookingPage, for: storeId, with: details)
                    self.present(bookingFlowHost, animated: true)
                }
            }
        }
    }
    
    // ...
    
    // MARK: FlowController
    
    func continueToBooking(startAt bookingPage: AppPage.Main.Booking) {
        let bookingFlowHost = DefaultBookingFlowHost(...)
        bookingFlowHost.start(bookingPage, with: details)
        self.present(bookingFlowHost, animated: true)
    }
    
    func bookingComplete(continueTo page: AppPage.Main) {
        dismiss(animated: false) {
            self.go(to: page)
        }
    }
    
    // ...
    
}
```

## TODO
- Register for remote notifications
- Handle app lifecycle events
- Networking
- Remote config / feature toggling
- Localisation
- Handle resources (swiftgen)
