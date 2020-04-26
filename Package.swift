// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "view-kit",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "ViewKit", targets: ["ViewKit"]),
        .library(name: "ViewKitDynamic", type: .dynamic, targets: ["ViewKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
    ],
    targets: [
        .target(name: "ViewKit", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Leaf", package: "leaf"),
        ]),
        .testTarget(name: "ViewKitTests", dependencies: ["ViewKit"]),
    ]
)
