# Flow View / ViewModel Pattern

A SwiftUI navigation pattern. Inspired by [Flow Navigation With SwiftUI 4](https://betterprogramming.pub/flow-navigation-with-swiftui-4-e006882c5efa).

The basic idea:
- **Pages:** Nested enums representing pages in the app, and the logical navigation path to them (root enum `AppPage`).
    - The main purpose is to represent deep links into content in the app.
- **App dependencies singleton:** Singleton holding a reference to / value of all shared services/utilities etc (`AppDependencies`).
- **Flow Coordinators, Flow Views and Flow ViewModels:** The protocol representing the interface to a View hierarchy's routing/navigation entity. Implemented by FlowViewModels, which holds the state of a view hierarchy logically grouped together by navigation flow. FlowViewModels is accompanied by a FlowView, representing the actual root view / container view at the top of a navigation path.
- **FlowViewFactories (or just ViewFactories):** Protocols representing the interface to an entity responsible for instantiating and constructing Views and ViewModels. A nice way to implement the ViewFactories, is by using a singleton shared across the whole app. The singleton implements all the ViewFactory protocols, but is abstracted away from the FlowViews who uses it. The ViewFactory is constructor-injected (together with FlowViewModels).

## Tips

### Avoid custom explicit View struct initialisers

[Link to StackOverflow post about the topic](https://stackoverflow.com/questions/73271168/a-swiftui-views-default-memberwise-initializer-vs-custom-initializer)

```swift
@main
struct MyApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {

    @AppStorage("redBackground") private var redBackground: Bool = false

    var body: some View {
        ZStack {
            // Flipping "redBackground" will cause a reconstruction of the view hierarchy
            if redBackground {
                Color.red
            } else {
                Color.green
            }
            MyView(viewModel: MyViewModel())
        }
    }
}

final class MyViewModel: ObservableObject {

    init() {
        print("MyViewModel.init")
    }
}

struct MyView: View {

    @StateObject var viewModel: MyViewModel

    @AppStorage("redBackground") private var redBackground: Bool = false

    // WARNING: Uncommenting this causes the view model to be recreated every reconstruction of the view!
    //    init(viewModel: MyViewModel) {
    //        self._viewModel = StateObject(wrappedValue: viewModel)
    //    }
    
    // NOTE: The proper way to pas arguments to a StateObject, is in the form of an @autoclosure like so:
    //    init(viewModel: @autoclosure @escaping () -> MyViewModel) {
    //        self._viewModel = StateObject(wrappedValue: viewModel())
    //    }

    var body: some View {
        VStack {
            Button("Toggle background") {
                redBackground = !redBackground
            }
        }
    }
}
```
