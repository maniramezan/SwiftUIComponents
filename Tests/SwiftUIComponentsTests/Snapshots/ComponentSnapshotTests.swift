import Foundation
import SnapshotTesting
import SwiftUI
import Testing

@testable import Components
@testable import DesignSystem

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

/// Tag for snapshot tests that should only run locally (not in CI).
///
/// Snapshot rendering is environment-sensitive — font metrics and antialiasing
/// differ across macOS/Xcode versions, making pixel comparison unreliable in CI.
/// These tests exist to **generate** DocC images locally, not for regression.
extension Tag {
    @Tag static var localOnly: Self
}

/// Snapshot tests for generating DocC documentation images.
///
/// These tests are **local-only** — they generate baseline images for use in
/// DocC documentation but are skipped in CI because pixel rendering varies
/// across environments.
///
/// ## Workflow
///
/// ```bash
/// # Generate or update baseline images:
/// SNAPSHOT_TESTING_RECORD=1 swift test --filter ComponentSnapshot
///
/// # Copy into DocC Resources:
/// ./Scripts/copy-snapshots-to-docc.sh
///
/// # Commit the baselines:
/// git add Tests/SwiftUIComponentsTests/Snapshots/__Snapshots__
/// git add Sources/Components/Components.docc/Resources
/// ```
@Suite(
    "Component Snapshots",
    .tags(.localOnly),
    .enabled(
        if: ProcessInfo.processInfo.environment["CI"] == nil,
        "Skipped in CI — snapshot rendering is environment-sensitive"
    )
)
struct ComponentSnapshotTests {

    // MARK: - Buttons

    @Test
    @MainActor func designButtons() {
        let view = VStack(spacing: 12) {
            DesignButton("Primary") {}
            DesignButton("Secondary", role: .secondary) {}
            DesignButton("Tertiary", role: .tertiary) {}
            DesignButton("Delete", role: .destructive) {}
            DesignButton("Loading", isLoading: true) {}
        }
        .padding()
        .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 340))
    }

    // MARK: - Search Bar

    @Test
    @MainActor func designSearchBar() {
        let view = DesignSearchBar(text: .constant(""), placeholder: "Search components")
            .padding()
            .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 80))
    }

    // MARK: - Toggle

    @Test
    @MainActor func designToggle() {
        let view = VStack(spacing: 12) {
            Toggle("Enabled", isOn: .constant(true))
                .toggleStyle(DesignToggleStyle())
            Toggle("Disabled", isOn: .constant(false))
                .toggleStyle(DesignToggleStyle())
        }
        .padding()
        .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 120))
    }

    // MARK: - Badge

    @Test
    @MainActor func designBadges() {
        let view = HStack(spacing: 8) {
            DesignBadge("Beta")
            DesignBadge("New", isProminent: true)
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 200, height: 60))
    }

    // MARK: - Pill Chip

    @Test
    @MainActor func designPillChips() {
        let view = HStack(spacing: 8) {
            DesignPillChip("All", isSelected: true) {}
            DesignPillChip("Active", isSelected: false) {}
            DesignPillChip("Archived", isSelected: false) {}
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 60))
    }

    // MARK: - Text Styles

    @Test
    @MainActor func designTextStyles() {
        let view = VStack(alignment: .leading, spacing: 8) {
            Text("Title").designTextStyle(.title)
            Text("Headline").designTextStyle(.headline)
            Text("Body").designTextStyle(.body)
            Text("Secondary").designTextStyle(.secondary)
            Text("Caption").designTextStyle(.caption)
            Text("Error").designTextStyle(.error)
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 260))
    }

    // MARK: - Surfaces

    @Test
    @MainActor func designCardSurface() {
        let view = Text("Card Surface")
            .padding()
            .designCardSurface()
            .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 100))
    }

    @Test
    @MainActor func designCapsuleSurface() {
        let view = HStack(spacing: 12) {
            Text("Default")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .designCapsuleSurface()
            Text("Selected")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .designCapsuleSurface(isSelected: true)
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 80))
    }

    @Test
    @MainActor func designInputSurface() {
        let view = Text("Input field")
            .padding()
            .designInputSurface()
            .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 100))
    }

    // MARK: - Containers

    @Test
    @MainActor func designContainers() {
        let view = VStack(spacing: 12) {
            DesignContainer(style: .card) { Text("Card container") }
            DesignContainer(style: .elevated) { Text("Elevated container") }
            DesignContainer(style: .outlined) { Text("Outlined container") }
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 260))
    }

    // MARK: - Empty State

    @Test
    @MainActor func designEmptyState() {
        let view = DesignEmptyStateView(
            title: "No Components",
            message: "Create your first reusable component to get started.",
            systemImage: "shippingbox"
        ) {
            DesignButton("Create Component") {}
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 300))
    }

    // MARK: - Loading

    @Test
    @MainActor func designLoading() {
        let view = DesignLoadingView("Loading components…")
            .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 120))
    }
}

// MARK: - Helpers

extension ComponentSnapshotTests {

    /// Renders the view and compares against the stored baseline.
    @MainActor
    private func assertComponentSnapshot<V: View>(
        _ view: V,
        size: CGSize,
        file: StaticString = #filePath,
        function: String = #function,
        line: UInt = #line
    ) {
        #if canImport(UIKit)
            assertSnapshot(
                of: view,
                as: .image(layout: .fixed(width: size.width, height: size.height)),
                file: file,
                testName: function,
                line: line
            )
        #elseif canImport(AppKit)
            let hostingView = NSHostingController(rootView: view)
            hostingView.view.frame = CGRect(origin: .zero, size: size)
            assertSnapshot(
                of: hostingView.view,
                as: .image(size: size),
                file: file,
                testName: function,
                line: line
            )
        #endif
    }
}
