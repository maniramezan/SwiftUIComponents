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
        // Single dynamic image over both library targets.
        //
        // The products above are static, so an app whose own modules are dynamic
        // frameworks links a separate copy of these targets into each one. The ObjC
        // runtime then reports `Class ...BundleFinder is implemented in both ...` and
        // binds `Bundle(for:)` to an arbitrary duplicate, so `Components`' generated
        // `Bundle.module` searches whichever framework won. An app survives that because
        // `Bundle.main` is checked first, but a hostless test bundle has the xctest agent
        // as `Bundle.main`, the lookup fails, and the test host dies.
        //
        // Link this product instead of the two static ones to collapse the graph to one
        // loaded image. `import DesignSystem` and `import Components` are unchanged.
        .library(
            name: "SwiftUIComponentsDynamic",
            type: .dynamic,
            targets: ["DesignSystem", "Components"]
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
