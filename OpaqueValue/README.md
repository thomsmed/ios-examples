# Representing arbitrary data as an opaque Codable type

This example app illustrate the concept of an opaque Codable type that can represent arbitrary (Codable) data. E.g some arbitrary JSON.
The type consists of one or more primitive types and/or one or more nested opaque values.

This code is heavily inspired by [Rob Napier](https://stackoverflow.com/users/97337/rob-napier)'s answer to this [StackOverflow post](https://stackoverflow.com/questions/65901928/swift-jsonencoder-encoding-class-containing-a-nested-raw-json-object-literal).
