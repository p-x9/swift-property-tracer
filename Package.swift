// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

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
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            "509.0.0"..<"511.0.0"
        ),
    ],
    targets: [
        .target(
            name: "PropertyTracer",
            dependencies: [
                "PropertyTracerSupport",
                "PropertyTracerPlugin"
            ]
        ),
        .target(
            name: "PropertyTracerSupport"
        ),
        .macro(
            name: "PropertyTracerPlugin",
            dependencies: [
                "PropertyTracerSupport",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "PropertyTracerTests",
            dependencies: [
                "PropertyTracer",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
    ]
)
