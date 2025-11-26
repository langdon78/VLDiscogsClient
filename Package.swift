// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VLDiscogsClient",
    platforms: [.iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VLDiscogsClient",
            targets: ["VLDiscogsClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/langdon78/VLNetworkingClient", .upToNextMajor(from: "0.1.5-alpha")),
        .package(url: "https://github.com/langdon78/VLOAuthFlowCoordinator", .upToNextMajor(from: "0.1.0-alpha"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VLDiscogsClient",
            dependencies: [
                .product(name: "VLNetworkingClient", package: "VLNetworkingClient"),
                .product(name: "VLOAuthFlowCoordinator", package: "VLOAuthFlowCoordinator")
            ]
        ),
        .testTarget(
            name: "VLDiscogsClientTests",
            dependencies: ["VLDiscogsClient"]
        ),
    ]
)
