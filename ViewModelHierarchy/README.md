# Driving SwiftUI navigation with a hierarchy of ViewModels

This example builds upon [Action emitting ViewModels and Coordinator Views](../ActionableViewModel), but with one change: ViewModels are now organized in an explicit hierarchy where each ViewModel is attached (and managed) by its ancestor ViewModel. Only the top most ViewModel (the "root" ViewModel) is managed as a @State/@StateObject by SwiftUI, all other ViewModels of significant importance are attached to the View hierarchy as @Bindables or @ObservableObjects.

## Deep Linking

Handling deep linking with this kind of ViewModel hierarchy is also a breeze! Check out [ViewModelHierarchyApp](ViewModelHierarchy/ViewModelHierarchyApp).

### Example Deep Links

Using Universal Links:

> Note: Need to have configured `apple-app-site-association`.

- https://ios.example.ViewModelHierarchy/app/root/about
- https://ios.example.ViewModelHierarchy/app/root/main/home/home
- https://ios.example.ViewModelHierarchy/app/root/main/home/profile
- https://ios.example.ViewModelHierarchy/app/root/main/more/more
- https://ios.example.ViewModelHierarchy/app/root/main/more/details
- https://ios.example.ViewModelHierarchy/app/root/main/settings

```bash
xcrun simctl openurl booted "https://ios.example.ViewModelHierarchy/app/root/about"
```

Or using custom URL scheme:

- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/about
- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/main/home/home
- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/main/home/profile
- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/main/more/more
- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/main/more/details
- ios.example.ViewModelHierarchy://ios.example.ViewModelHierarchy/app/root/main/settings
