// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HTTPServer",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        .executableTarget(
            name: "HTTPServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        )
    ]
)
