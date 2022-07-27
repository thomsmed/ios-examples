# Bluetooth Low Energy (BLE) Chat App

A simple chat app showcasing Bluetooth Low Energy and Apple's Core Bluetooth framework.

Install the app on two iOS devices and start chatting 🙌

## Custom run loop input source

Example usage of custom [run loop input source](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW3) (check out [StopRunLoopSource](BLEChat/Utils/StopRunLoopSource.swift)) together with a dedicated thread to process stream events when streaming data over a L2CAP Channel.
