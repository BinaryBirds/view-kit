// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "view-kit",
    platforms: [
       .macOS(.v11)
    ],
    products: [
        .library(name: "ViewKit", targets: ["ViewKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.35.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf", .exact("4.0.0-tau.1")),
        .package(url: "https://github.com/vapor/leaf-kit", .exact("1.0.0-tau.1.1")),
        .package(url: "https://github.com/vapor/fluent-kit", from: "1.0.0"),
    ],
    targets: [
        .target(name: "ViewKit", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "LeafKit", package: "leaf-kit"),
        ]),
        .testTarget(name: "ViewKitTests", dependencies: [
            .target(name: "ViewKit"),
            .product(name: "XCTFluent", package: "fluent-kit"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
