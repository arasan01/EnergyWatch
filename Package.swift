// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppLib",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AppLib",
            targets: ["AppLib"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppLib",
            resources: [
                .process("Assets")
            ]),
        .testTarget(
            name: "LibTests",
            dependencies: ["AppLib"]),
    ]
)
