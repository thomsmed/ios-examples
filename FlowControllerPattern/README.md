# Flow Controller / Flow Coordinator Pattern

An app navigation pattern.

Key takeaways:
- Flow Controller / Flow Coordinator Pattern:
    - AppPage - Nested enums with associated values, describing content / pages in the app.
    - FlowController / FlowCoordinator and FlowHost - Protocols implemented by container view controllers. Where FlowHost is acting as an interface "down" the navigation hierarchy, and FlowController/FlowCoordinator acting as an interface "up" the navigation hierarchy.
    - ViewHolder - Protocol implemented by view controllers. The protocol is acting as the view controller's "public" interface.
    - FlowFactory - Responsible for the instantiation of all FlowControllers/FlowCoordinators, FlowHosts and ViewHolders (and other objects as needed).
- AppConfiguration - Interface exposing configuration properties (usually from .plist files), like app bundle display name or credentials for authentication services etc.
- DefaultsRepository - Interface exposing methods to get and set defaults values that affect the app's content or navigation flow. E.g. if the user has completed onboarding.
- AnalyticsLogger - Interface exposing methods to log analytics events.
- CrashlyticsRecorder - Interface exposing methods to record and track errors.
- RemoteConfiguration - Interface exposing configuration properties that tell something about what or how content should be available to the user (e.g. toggling features on/off).

## AppPage

```swift
// Defining all app-pages that can be deep linked to (via e.g. Universal Links),
// or pages the user can jump to with one click (e.g jumping from Profile to ShoppingCart under the Booking flow)
// Thought of as representing an URL, e.g.: https://www.myapp.com/app/main/booking/{storeId}/checkout?service=123&product=123
enum AppPage {
    enum Main {
        enum Booking {
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

## FlowController / FlowCoordinator and FlowHost

Protocols

```swift
// Exposed to ViewModels and child FlowHosts
protocol MainFlowCoordinator: AnyObject {
    // Where to go next? Where to start after that?
    func continueToBooking(startAt bookingPage: AppPage.Main.Booking)
    // What just happened? Where to go next?
    func bookingComplete(continueTo page: AppPage.Main)
}

// Exposed to parent FlowHosts
protocol MainFlowHost: MainFlowCoordinator & UIViewController {
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
    private weak var flowCoordinator: AppFlowCoordinator?

    private var homeFlowHost: HomeFlowHost?
    private var activitiesFlowHost: ActivitiesFlowHost?
    private var profileFlowHost: ProfileFlowHost?
    private var bookingFlowHost: BookingFlowHost?
    
    // ...
    
    init(flowFactory: MainFlowFactory, flowCoordinator: AppFlowCoordinator) {
        self.flowFactory = flowFactory
        self.flowCoordinator = flowCoordinator
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
    
    // MARK: MainFlowCoordinator
    
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
// The root view/view controller of every page needs to be associated with a ViewHolder protocol.
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
    
    func makeExploreFlowHost(with flowCoordinator: MainFlowCoordinator) -> ExploreFlowHost
    func makeActivityFlowHost(with flowCoordinator: MainFlowCoordinator) -> ActivityFlowHost
    func makeProfileFlowHost(with flowCoordinator: MainFlowCoordinator) -> ProfileFlowHost
    func makeBookingFlowHost(with flowCoordinator: MainFlowCoordinator) -> BookingFlowHost
    
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

    func makeExploreFlowHost(with flowCoordinator: MainFlowCoordinator) -> ExploreFlowHost {
        DefaultExploreFlowHost(
            flowFactory: self,
            flowCoordinator: flowCoordinator
        )
    }

    // ...

    func makeBookingFlowHost(with flowCoordinator: MainFlowCoordinator) -> BookingFlowHost {
        DefaultBookingFlowHost(
            flowFactory: self,
            flowCoordinator: flowCoordinator
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
        with flowCoordinator: BookingFlowCoordinator,
        using shoppingCart: ShoppingCart
    ) -> CheckoutViewHolder {
        CheckoutViewController(
            viewModel: .init(
                flowCoordinator: flowCoordinator,
                bookingService: appDependencies.bookingService,
                shoppingCart: shoppingCart
            )
        )
    }
    
    // ...
}
```

## Push notifications

```bash
xcrun simctl push <device-identifier> com.thomsmed.FlowControllerPattern ExamplePush.apns

// For iPhone 13 Pro simulator:
xcrun simctl push "2216FFD1-B7AF-4676-B888-A0A8F2509FE9" com.thomsmed.FlowControllerPattern ExamplePush.apns
```

## TODO
- Networking
