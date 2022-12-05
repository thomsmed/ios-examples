# Multi Module App

And example of how to spread app features into multiple feature modules (Swift Packages).

The Coordinator pattern is used as a navigation pattern and a way to separate responsibility (and features).
Each feature module's entry point is a feature specific root Coordinator implementation. Notifications (e.g. when the feature has completed normal flow) are exposed via a CoordinatorDelegate.
