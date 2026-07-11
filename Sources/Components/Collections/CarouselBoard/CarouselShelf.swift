import DesignSystem
import SwiftUI

/// One shelf in a ``CarouselBoard``: a themed ``SectionHeader`` above a
/// horizontal row of content.
///
/// A shelf can be **data-backed** — supply items and an item view, and the shelf
/// builds a ``CarouselRow`` for you — or **fully custom** — supply the entire
/// row view yourself. Because each shelf erases its content to `AnyView`, a
/// single board can mix shelves with completely different item types.
///
/// ```swift
/// CarouselBoard {
///     // Data-backed, peeking cards
///     CarouselShelf("Featured", items: apps) { app in FeaturedCard(app) }
///
///     // Data-backed, fixed-width tiles + a "See All" action
///     CarouselShelf("Top Free", items: apps, actionLabel: "See All",
///                   sizing: .fixedWidth(120), onSeeAll: { open() }) { app in
///         IconTile(app)
///     }
///
///     // Fully custom row
///     CarouselShelf("Editor's Pick") { EditorsBanner() }
/// }
/// ```
public struct CarouselShelf: CarouselShelfConvertible {

    private let title: String
    private let actionLabel: String?
    private let onSeeAll: (() -> Void)?
    private let titleFont: Font?
    /// Builds the row lazily on the main actor. Deferring construction keeps the
    /// (nonisolated) initializers free of the main-actor-isolated `CarouselRow`
    /// initializer and its `View`/`Hashable` conformance requirements.
    private let makeRow: @MainActor () -> AnyView

    /// A stable identifier derived from the shelf title.
    public let shelfID: AnyHashable

    // MARK: - Data-backed initializers

    /// Creates a data-backed shelf keyed by an explicit key path.
    ///
    /// - Parameters:
    ///   - title: The shelf's header title. Rendered verbatim — localize before
    ///     passing.
    ///   - items: The items shown in the shelf's row.
    ///   - id: A key path to a stable, hashable identifier for each item.
    ///   - actionLabel: Optional trailing action title (e.g. "See All"). The
    ///     action appears only when both this and `onSeeAll` are non-`nil`.
    ///   - sizing: How each item is sized. Defaults to a single peeking item.
    ///   - onSeeAll: Optional handler for the trailing action.
    ///   - rows: The number of stacked rows items flow into. Defaults to `1`.
    ///   - rowHeight: The height of one row; required when `rows` > `1`.
    ///   - titleFont: Optional override for the header title's font. When
    ///     `nil` (the default), ``SectionHeader``'s standard font is used.
    ///   - content: A view builder invoked for each item.
    @MainActor
    public init<Item, ID: Hashable, ItemContent: View>(
        _ title: String,
        items: [Item],
        id: KeyPath<Item, ID>,
        actionLabel: String? = nil,
        sizing: CarouselItemSizing = .peek(),
        onSeeAll: (() -> Void)? = nil,
        rows: Int = 1,
        rowHeight: CGFloat? = nil,
        titleFont: Font? = nil,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.title = title
        self.actionLabel = actionLabel
        self.onSeeAll = onSeeAll
        self.titleFont = titleFont
        self.shelfID = AnyHashable(title)
        self.makeRow = {
            AnyView(
                CarouselRow(
                    items,
                    id: id,
                    sizing: sizing,
                    rows: rows,
                    rowHeight: rowHeight,
                    content: content
                )
            )
        }
    }

    /// Creates a data-backed shelf over `Identifiable` items, using each
    /// element's `id` automatically.
    ///
    /// - Parameters:
    ///   - title: The shelf's header title. Rendered verbatim — localize before
    ///     passing.
    ///   - items: The items shown in the shelf's row.
    ///   - actionLabel: Optional trailing action title (e.g. "See All"). The
    ///     action appears only when both this and `onSeeAll` are non-`nil`.
    ///   - sizing: How each item is sized. Defaults to a single peeking item.
    ///   - onSeeAll: Optional handler for the trailing action.
    ///   - rows: The number of stacked rows items flow into. Defaults to `1`.
    ///   - rowHeight: The height of one row; required when `rows` > `1`.
    ///   - titleFont: Optional override for the header title's font.
    ///   - content: A view builder invoked for each item.
    @MainActor
    public init<Item: Identifiable, ItemContent: View>(
        _ title: String,
        items: [Item],
        actionLabel: String? = nil,
        sizing: CarouselItemSizing = .peek(),
        onSeeAll: (() -> Void)? = nil,
        rows: Int = 1,
        rowHeight: CGFloat? = nil,
        titleFont: Font? = nil,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.init(
            title,
            items: items,
            id: \.id,
            actionLabel: actionLabel,
            sizing: sizing,
            onSeeAll: onSeeAll,
            rows: rows,
            rowHeight: rowHeight,
            titleFont: titleFont,
            content: content
        )
    }

    // MARK: - Fully custom initializer

    /// Creates a shelf whose horizontal content you supply directly, bypassing
    /// ``CarouselRow``.
    ///
    /// - Parameters:
    ///   - title: The shelf's header title. Rendered verbatim — localize before
    ///     passing.
    ///   - actionLabel: Optional trailing action title. The action appears only
    ///     when both this and `onSeeAll` are non-`nil`.
    ///   - onSeeAll: Optional handler for the trailing action.
    ///   - titleFont: Optional override for the header title's font.
    ///   - content: A view builder returning the entire row content.
    @MainActor
    public init<RowContent: View>(
        _ title: String,
        actionLabel: String? = nil,
        onSeeAll: (() -> Void)? = nil,
        titleFont: Font? = nil,
        @ViewBuilder content: @escaping () -> RowContent
    ) {
        self.title = title
        self.actionLabel = actionLabel
        self.onSeeAll = onSeeAll
        self.titleFont = titleFont
        self.shelfID = AnyHashable(title)
        self.makeRow = { AnyView(content()) }
    }

    // MARK: - CarouselShelfConvertible

    /// Builds the shelf: a ``SectionHeader`` above the row content.
    public func makeShelf() -> AnyView {
        AnyView(
            CarouselShelfLayout(
                title: title,
                actionLabel: actionLabel,
                onSeeAll: onSeeAll,
                titleFont: titleFont,
                row: makeRow()
            )
        )
    }
}

// MARK: - Layout

/// Stacks a shelf's header above its row with theme-derived spacing.
private struct CarouselShelfLayout: View {

    let title: String
    let actionLabel: String?
    let onSeeAll: (() -> Void)?
    let titleFont: Font?
    let row: AnyView

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            SectionHeader(
                title: title,
                actionLabel: actionLabel,
                onAction: onSeeAll,
                titleFont: titleFont
            )
            row
        }
    }
}
