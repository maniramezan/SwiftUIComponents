// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIComponents",
    defaultLocalization: "en",
    platforms: [.macOS(.v15), .iOS(.v18), .macCatalyst(.v18)],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        ),
        .library(
            name: "Components",
            targets: ["Components"]
        ),
        .library(
            name: "ComponentShowcase",
            targets: ["ComponentShowcase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.3"),
    ],
    targets: [
        .target(
            name: "DesignSystem"
        ),
        .target(
            name: "Components",
            dependencies: ["DesignSystem"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SwiftUIComponentsTests",
            dependencies: [
                "Components",
                "DesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["Snapshots/__Snapshots__"]
        ),
        .target(
            name: "ComponentShowcase",
            dependencies: ["Components", "DesignSystem"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
