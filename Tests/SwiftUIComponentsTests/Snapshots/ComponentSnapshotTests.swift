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
            ThemeButton("Primary") {}
            ThemeButton("Secondary", role: .secondary) {}
            ThemeButton("Tertiary", role: .tertiary) {}
            ThemeButton("Delete", role: .destructive) {}
            ThemeButton("Loading", isLoading: true) {}
        }
        .padding()
        .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 340))
    }

    // MARK: - Search Bar

    @Test
    @MainActor func designSearchBar() {
        let view = SearchBar(text: .constant(""), placeholder: "Search components")
            .padding()
            .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 80))
    }

    // MARK: - Toggle

    @Test
    @MainActor func designToggle() {
        let view = VStack(spacing: 12) {
            Toggle("Enabled", isOn: .constant(true))
                .toggleStyle(ThemeToggleStyle())
            Toggle("Disabled", isOn: .constant(false))
                .toggleStyle(ThemeToggleStyle())
        }
        .padding()
        .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 120))
    }

    // MARK: - Badge

    @Test
    @MainActor func designBadges() {
        let view = HStack(spacing: 8) {
            Badge("Beta")
            Badge("New", isProminent: true)
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 200, height: 60))
    }

    // MARK: - Pill Chip

    @Test
    @MainActor func designPillChips() {
        let view = HStack(spacing: 8) {
            PillChip("All", isSelected: true) {}
            PillChip("Active", isSelected: false) {}
            PillChip("Archived", isSelected: false) {}
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
            Container(style: .card) { Text("Card container") }
            Container(style: .elevated) { Text("Elevated container") }
            Container(style: .outlined) { Text("Outlined container") }
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 260))
    }

    // MARK: - Empty State

    @Test
    @MainActor func designEmptyState() {
        let view = EmptyStateView(
            title: "No Components",
            message: "Create your first reusable component to get started.",
            systemImage: "shippingbox"
        ) {
            ThemeButton("Create Component") {}
        }
        .padding()

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 300))
    }

    // MARK: - Error Feedback

    @Test
    @MainActor func designErrorBanner() {
        let view = ErrorBanner("Something went wrong. Please try again.")
            .padding()
            .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 80))
    }

    @Test
    @MainActor func designErrorSection() {
        let view = Form {
            ErrorSection(message: "Could not load data. Check your connection.")
        }
        .frame(width: 320)

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 120))
    }

    // MARK: - Adaptive Surfaces

    @Test
    @MainActor func designAdaptiveSurface() {
        let view = VStack(spacing: 16) {
            Text("Default")
                .padding()
                .designAdaptiveSurface()
            Text("With Tint")
                .padding()
                .designAdaptiveSurface(tint: .blue.opacity(0.2))
            Text("Selected")
                .padding()
                .designSelectableCardSurface(isSelected: true)
            Text("Unselected")
                .padding()
                .designSelectableCardSurface(isSelected: false)
        }
        .padding()
        .frame(width: 320)
        .background(Color.teal.opacity(0.3))

        assertComponentSnapshot(view, size: CGSize(width: 320, height: 280))
    }

    // MARK: - Navigation

    @Test
    @MainActor func designPagedView() {
        struct SnapshotPage: Identifiable {
            let id: Int
            let title: String
            let symbol: String
        }
        let pages: [SnapshotPage] = [
            .init(id: 0, title: "Best of 2025", symbol: "sparkles"),
            .init(id: 1, title: "Spotlight: Health", symbol: "heart.fill"),
            .init(id: 2, title: "Travel Companions", symbol: "airplane"),
        ]
        let view = TitledPageView(pages, selection: .constant(0), title: \SnapshotPage.title) { page in
            VStack(spacing: 8) {
                Image(systemName: page.symbol)
                    .font(.system(size: 40, weight: .semibold))
                Text(page.title)
                    .designTextStyle(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .designCardSurface()
            .padding(.horizontal, 8)
        }
        .frame(width: 390)

        assertComponentSnapshot(view, size: CGSize(width: 390, height: 280))
    }

    // MARK: - Loading

    @Test
    @MainActor func designLoading() {
        let view = LoadingView("Loading components…")
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
