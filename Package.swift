// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fairy",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "Fairy",
            targets: ["Fairy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.18.0"),
        .package(url: "https://github.com/duraidabdul/LocalConsole", from: "1.12.1"),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Fairy",
            dependencies: [
                "FairyFBAdapter",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "Popovers"
            ]
        ),
        .target(
            name: "FairyFBAdapter",
            dependencies: [
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ],
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "FairyTests",
            dependencies: ["Fairy"]
        ),
    ]
)
