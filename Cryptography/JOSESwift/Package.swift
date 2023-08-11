// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JOSESwift",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "JOSESwift",
            targets: ["JOSESwift"]),
    ],
    targets: [
        .target(
            name: "JOSESwift"),
        .testTarget(
            name: "JOSESwiftTests",
            dependencies: ["JOSESwift"]),
    ]
)
