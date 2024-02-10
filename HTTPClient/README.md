# General purpose HTTPClient with support for interceptors

A simple Server/Client example of communication over HTTP, with a general purpose HTTPClient supporting interceptors.

## HTTP Client (iOS app)

A simple SwiftUI iOS app communicating to a remove Web Server using HTTP,
using a general purpose HTTPClient with support for interceptors.

Select the `HTTPClient` scheme to build and run the iOS app.

Note: Works best in Simulator, as the accompanied Terminal/Server application listen on `localhost:8080`.

## HTTP Server (Terminal app)

A simple Terminal/Server app acting as a Web Server, and accepting HTTP requests.

Built using [Vapor](https://docs.vapor.codes/).

```bash
# Instal the Vapor toolbox
brew install vapor

# Bootstrap a new Vapor based Swift Terminal/Server app
vapor new HelloVapor
```

Select the `HTTPServer` scheme to build and run the Terminal/Server app.

Note: The Terminal/Server app is listening on `localhost:8080` by default.
