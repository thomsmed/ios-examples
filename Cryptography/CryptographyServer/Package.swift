// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CryptographyServer",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/beatt83/jose-swift.git", from: "1.2.2"),
    ],
    targets: [
        .executableTarget(
            name: "CryptographyServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "jose-swift", package: "jose-swift")
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        )
    ]
)
