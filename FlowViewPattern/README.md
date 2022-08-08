# Flow View / ViewModel Pattern

A SwiftUI navigation pattern.

### TODOs
- Handle deep links (navigation "down" the tree)
- Handle navigation as a result of user actions (navigation "up" the tree)
- Custom Presentation Container View (SingeView and SegmentedView)

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
