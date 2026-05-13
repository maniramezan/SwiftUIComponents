// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIComponents",
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
            dependencies: ["Components", "DesignSystem"],
        ),
    ],
    swiftLanguageModes: [.v6]
)
