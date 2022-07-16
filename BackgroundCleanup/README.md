# Background refresh and cleanup

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
