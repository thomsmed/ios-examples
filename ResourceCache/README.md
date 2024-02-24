# Concurrent and thread safe resource cache with Swift Concurrency

This project contains a simple app with some examples of possible ways to build a concurrent and thread safe resource cache (caching of remotely fetched resources).

Profile the example app with the [Instruments](https://developer.apple.com/videos/play/wwdc2019/411/) tool using the Swift Concurrency profiling template,
and see how the different resource cache implementations behave in terms of Task creation etc.

The code is heavily inspired by these WWDC videos (which I really recommend watching!):

- [Eliminate data races using Swift Concurrency](https://developer.apple.com/videos/play/wwdc2022/110351/).
- [Swift concurrency: Behind the scenes](https://developer.apple.com/videos/play/wwdc2021/10254/).
- [Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/).
- [Visualize and optimize Swift concurrency](https://developer.apple.com/videos/play/wwdc2022/110350/).

This project also contain some example utility classes for safely managing protected values across Threads / concurrency contexts:

- [AtomicCount](ResourceCache/Utils/AtomicCount.swift): A Thread safe counter value using [Swift Atomics](https://github.com/apple/swift-atomics).
- [LockedCount](ResourceCache/Utils/LockedCount.swift): A Thread safe counter value using [NSLock](https://developer.apple.com/documentation/foundation/nslock).
- [WaitingContinuationsLocker](ResourceCache/Utils/WaitingContinuationsLocker.swift): Thread safe storage for Continuations of a particular type (waiting to be resumed).

Some Unit Tests are included to help show the differences between the different implementations of a resource cache,
but due to the nature of concurrency they are most reliable when ran individually.
