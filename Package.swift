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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.30.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0-rc"),
    ],
    targets: [
        .target(name: "ViewKit", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
        ]),
        .testTarget(name: "ViewKitTests", dependencies: [
            .target(name: "ViewKit"),
            .product(name: "XCTFluent", package: "fluent-kit"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
