// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "is_ios_simulator",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "is-ios-simulator", targets: ["is_ios_simulator"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "is_ios_simulator",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("Resources"),
            ]
        )
    ]
)
