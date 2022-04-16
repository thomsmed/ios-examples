//
//  StopRunLoopSource.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 17/04/2022.
//

import Foundation

final class StopRunLoopSource: NSObject {

    // More on how to define custom run loop input sources: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW3
    // And tips on how to terminate threads: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW10

    static let threadDictionaryKey = "stop"

    private let runLoopSource: CFRunLoopSource

    private var invalidated = false

    private weak var cfRunLoop: CFRunLoop?

    override init() {
        var context = CFRunLoopSourceContext(
            version: 0,
            info: nil,
            retain: nil,
            release: nil,
            copyDescription: nil,
            equal: nil,
            hash: nil,
            schedule: { _, runLoop, mode in
                // Called when the run loop source is attached to a run loop.
            },
            cancel: { _, runLoop, mode in
                // Called when the run loop source is invalidated.
            },
            perform: { _ in
                // Called when the run loop source is signalled (and the run loop is woken up.
                Thread.current.threadDictionary[StopRunLoopSource.threadDictionaryKey] = true
            }
        )
        runLoopSource = CFRunLoopSourceCreate(nil, 0, &context)

        super.init()
    }

    deinit {
        CFRunLoopSourceInvalidate(runLoopSource)
    }

    func schedule(in runLoop: RunLoop) {
        guard !invalidated else {
            return

        }

        let cfRunLoop = runLoop.getCFRunLoop()

        CFRunLoopAddSource(cfRunLoop, runLoopSource, CFRunLoopMode.defaultMode)

        self.cfRunLoop = cfRunLoop
    }

    func invalidate() {
        CFRunLoopSourceInvalidate(runLoopSource)

        invalidated = true
    }

    func signal() {
        guard !invalidated, let cfRunLoop = cfRunLoop else {
            return
        }

        CFRunLoopSourceSignal(runLoopSource);
        CFRunLoopWakeUp(cfRunLoop);
    }
}
