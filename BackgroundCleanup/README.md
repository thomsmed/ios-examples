# Background refresh and cleanup

A simple example on how to use the [Background Tasks](https://developer.apple.com/documentation/backgroundtasks) framework to schedule your app to do background work when the system (iOS) finds it fitting.

> NOTE: Even though your background tasks are scheduled successfully, they are never guaranteed to be run when you want them too. There are several factors that influences when the system actually decides to give your app some execution time in the background.

## Nice to know

For an awesome writeup on factors that effects the running of BackgroundTasks, check out this [article by Andy Ibanez](https://www.andyibanez.com/posts/common-reasons-background-tasks-fail-ios/).

Apple Developer Forums post worth checking out: [UIApplication Background Task Notes](https://developer.apple.com/forums/thread/85066)

### Execution time

It is worth noting that the system (iOS) might launch several of your background tasks at the same time. The running tasks will then share the available execution time the system has given your app, so you should always make sure that your tasks can run concurrent. Otherwise your tasks might not finish in time.

#### App Refresh Tasks

Currently [AppRefreshTasks](https://developer.apple.com/documentation/backgroundtasks/bgapprefreshtask) seems to be given around 30 seconds of execution time (the same as you get from using [UIApplication.beginBackgroundTask(expirationHandler:)](https://developer.apple.com/documentation/uikit/uiapplication/1623031-beginbackgroundtask)).

#### Processing Tasks

The documentation states that [ProcessingTasks](https://developer.apple.com/documentation/backgroundtasks/bgprocessingtask) can give your app _several_ minutes of background execution time, without giving an actual number.

> NOTE (From the docs): Processing tasks run only when the device is idle. The system terminates any background processing tasks running when the user starts using the device. Background refresh tasks are not affected. 


### System factors

Several system conditions, and other factors, effects when and if your scheduled background tasks are run: 

- App frequently used have a higher chance of having their background tasks run.
- Background tasks not relying on network, or that is not too power consuming, have a higher chance to be run.
- The system have a higher chance of running background tasks when the device is plugged in to a power source.
- Apps visible in the App Switcher (and not forcefully killed by the user) have a higher chance of having their background tasks run.
- App that have their Background App Refresh setting (in the Settings app) turned off, will not have their background tasks run. The setting is on by default.
 

## Debugging

### Launch a Task

Pause app (or stop at breakpoint) and start interactive debugging, then:

```bash
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.thomsmed.appRefreshTask"]
```

### Force early termination of a Task

Pause at a breakpoint inside a task, then:

```bash
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.thomsmed.appRefreshTask"]
```

## Bonus: Background URLSessions

You can schedule and download content in the background by configureing an URLSession as a Background URLSession. Check out more in [the docs](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background)
