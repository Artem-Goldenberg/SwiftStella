// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftStella",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Stella",
            targets: ["Stella"]),
    ],
    dependencies: [
        .package(url: "https://github.com/davedufresne/SwiftParsec", from: "4.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Stella",
            dependencies: [
                .product(name: "SwiftParsec", package: "SwiftParsec")
            ]
        ),
        .executableTarget(
            name: "TestGenerator",
            dependencies: ["Stella"],
            swiftSettings: [.unsafeFlags(["-parse-as-library"])]
        ),
        .testTarget(
            name: "StellaTests",
            dependencies: ["Stella"],
            resources: [
                .copy("Resources/stella-tests"),
                .copy("Resources/printed-trees")
            ]
        ),
    ]
)
