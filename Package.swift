// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "view-kit",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "ViewKit", targets: ["ViewKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.30.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        //.package(url: "https://github.com/vapor/leaf", from: "4.0.0"),
        .package(url: "https://github.com/tib/leaf", .branch("tau")),
        .package(url: "https://github.com/vapor/fluent-kit", from: "1.0.0"),
    ],
    targets: [
        .target(name: "ViewKit", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Leaf", package: "leaf"),
        ]),
        .testTarget(name: "ViewKitTests", dependencies: [
            .target(name: "ViewKit"),
            .product(name: "XCTFluent", package: "fluent-kit"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
