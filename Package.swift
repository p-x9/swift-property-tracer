// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PropertyTracer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "PropertyTracer",
            targets: ["PropertyTracer"]
        )
    ],
    targets: [
        .target(
            name: "PropertyTracer",
            dependencies: []
        ),
        .testTarget(
            name: "PropertyTracerTests",
            dependencies: []
        ),
    ]
)
