# Real-time with WebSockets and Swift Concurrency

A simple Server/Client example of communication over WebSockets.

## WebSocket Client (iOS app)

A simple SwiftUI iOS app communicating with a remove Web Server using WebSockets,
using a generic WebSocketConnection produced by a WebSocketConnectionFactory.

## WebSocket Server (Terminal app)

A simple Terminal/Server app acting as a Web Server, and accepting WebSocket connections.

Built using [Vapor](https://docs.vapor.codes/).

```bash
# Instal the Vapor toolbox
brew install vapor

# Bootstrap a new Vapor based Swift Terminal/Server app
vapor new HelloVapor
```

Select the `WebSocketServer` scheme to build and run the Terminal/Server app.

Note: The Terminal/Server app is listening on `localhost:8080` by default.
