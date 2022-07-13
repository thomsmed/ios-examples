# Flow Controller Pattern

An app navigation pattern

## AppPage

```swift
// Defining all app-pages that can be deep linked to (via e.g. Universal Links),
// or pages the user can jump to with one click (e.g jumping from Profile to ShoppingCart under the Booking flow)
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

## FlowController and FlowHost

Protocols

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

Implementation

```swift
final class DefaultMainFlowHost: UITabBarController {

    private let flowFactory: MainFlowFactory
    private weak var flowController: AppFlowController?

    private var homeFlowHost: HomeFlowHost?
    private var activitiesFlowHost: ActivitiesFlowHost?
    private var profileFlowHost: ProfileFlowHost?
    private var bookingFlowHost: BookingFlowHost?
    
    // ...
    
    init(flowFactory: MainFlowFactory, flowController: AppFlowController) {
        self.flowFactory = flowFactory
        self.flowController = flowController
    }
}

extension DefaultMainFlowHost: MainFlowHost {
    // MARK: MainFlowHost
    
    func start(_ page: AppPage.Main) {
        let homeFlowHost = flowFactory.makeHomeFlowHost(...)
        
        // ...
        
        switch page {
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
                    let bookingFlowHost = flowFactory.makeBookingFlowHost(...)
                    bookingFlowHost.start(bookingPage, for: storeId, with: details)
                    self.present(bookingFlowHost, animated: true)
                }
            }
        }
    }
    
    // ...
    
    // MARK: FlowController
    
    func continueToBooking(startAt bookingPage: AppPage.Main.Booking) {
        let bookingFlowHost = flowFactory.makeBookingFlowHost(...)
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


## ViewHolder

```swift
// The root view/view controller of every page needs to to be associated with a ViewHolder protocol.
// FlowHosts uses this protocol to send commands to the view (ViewHolders)
protocol StoreMapViewHolder: UIViewController {
    func selectStore(with storeId: String)
}

final class StoreMapViewController: UIViewController {

    // ..

}

// MARK: StoreMapViewHolder

extension StoreMapViewController: StoreMapViewHolder {

    func selectStore(with storeId: String) {
        
        // ...
        
    }
}

// ...

// Example use:
extension DefaultStoreFlowHost: StoreFlowHost {

    func start(_ page: PrimaryPage.Main.Explore.Store) {
        
        // ...
        
        switch page {
        case let .map(bookingPage, storeId):
            let storeMapViewHolder = flowFactory.makeStoreMapViewHolder()

            setViewController(storeMapViewHolder, using: .dissolve)

            self.storeMapViewHolder = storeMapViewHolder

            guard let storeId = storeId else {
                return
            }

            storeMapViewHolder.selectStore(with: storeId)

            // ..
            
        case .list:
        
            // ...
            
        }
        
    }

    // ...
    
}
```

## FlowFactory

Protocol

```swift
protocol MainFlowFactory: AnyObject {
    
    // ...
    
    func makeExploreFlowHost(with flowController: MainFlowController) -> ExploreFlowHost
    func makeActivityFlowHost(with flowController: MainFlowController) -> ActivityFlowHost
    func makeProfileFlowHost(with flowController: MainFlowController) -> ProfileFlowHost
    func makeBookingFlowHost(with flowController: MainFlowController) -> BookingFlowHost
    
    // ...
    
}
```

Implementation

```swift
// Typically only one class implement all the FlowFactory protocols:
final class DefaultAppFlowFactory {
    
    private let appDependencies: AppDependencies
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
    
    // ...
    
}

extension DefaultAppFlowFactory: MainFlowFactory {

    // ...

    func makeExploreFlowHost(with flowController: MainFlowController) -> ExploreFlowHost {
        DefaultExploreFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }

    // ...

    func makeBookingFlowHost(with flowController: MainFlowController) -> BookingFlowHost {
        DefaultBookingFlowHost(
            flowFactory: self,
            flowController: flowController
        )
    }
    
    // ...
}

// ...

extension DefaultAppFlowFactory: BookingFlowFactory {

    // ...

    func makeShoppingCart() -> ShoppingCart {
        ShoppingCart()
    }
    
    // ...

    func makeCheckoutViewHolder(
        with flowController: BookingFlowController,
        using shoppingCart: ShoppingCart
    ) -> CheckoutViewHolder {
        CheckoutViewController(
            viewModel: .init(
                flowController: flowController,
                bookingService: appDependencies.bookingService,
                shoppingCart: shoppingCart
            )
        )
    }
    
    // ...
}
```

## TODO
- Register for remote notifications
- Handle app lifecycle events
- Networking
- Remote config / feature toggling
- Localization
- Handle resources (swiftgen)
