import Components
import DesignSystem
import SwiftUI

struct PagedViewDetailView: View {

    fileprivate struct Page: Identifiable, Hashable {
        let id: Int
        let title: String
        let summary: String
        let symbol: String
    }

    private static let pages: [Page] = [
        .init(id: 0, title: "Best of 2025", summary: "Editors' picks from across the year.", symbol: "sparkles"),
        .init(
            id: 1, title: "Spotlight: Health", summary: "Apps to help you move, eat, sleep, breathe.",
            symbol: "heart.fill"),
        .init(id: 2, title: "Travel Companions", summary: "Plan, book, and remember every trip.", symbol: "airplane"),
        .init(
            id: 3, title: "Quiet Tools", summary: "Beautifully focused single-purpose apps.", symbol: "moon.stars.fill"),
    ]

    @State private var selection: Int = 0
    @State private var pageCount = 4
    @State private var reversed = false
    @State private var customChrome = false
    @State private var peekWidth = 40.0
    @State private var titleGap = 16.0
    @State private var headerSpacing = 16.0
    @State private var leadingInset = 0.0
    @State private var usesInset = false
    @State private var hintEnabled = false
    @State private var hintDelay = 0.6
    @State private var hintDistance = 40.0
    @State private var usesCrossfade = true
    @State private var titleColor = Color.primary
    @State private var adjacentColor = Color.secondary
    @State private var activeColor = Color.blue
    @State private var inactiveColor = Color.gray
    @State private var backgroundColor = Color.clear
    @State private var largeFont = false
    @State private var indicatorStyle: PaginationIndicatorStyle = .dots
    @State private var peekDirection: PaginationPeekDirection = .bidirectional
    @State private var titleAlignment: TitledPageTitleAlignment = .automatic
    @State private var isRTL = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            // Live controls
            ShowcaseSection("Configuration") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    PagedViewControlRow(label: "Indicator") {
                        ForEach([PaginationIndicatorStyle.dots, .bar, .hidden], id: \.self) { s in
                            PillChip(indicatorLabel(s), isSelected: indicatorStyle == s) { indicatorStyle = s }
                        }
                    }
                    PagedViewControlRow(label: "Peek") {
                        ForEach(PaginationPeekDirection.allCases, id: \.self) { d in
                            PillChip(peekLabel(d), isSelected: peekDirection == d) { peekDirection = d }
                        }
                    }
                    PagedViewControlRow(label: "Title") {
                        ForEach(
                            [TitledPageTitleAlignment.automatic, .leading, .center, .trailing, .hidden], id: \.self
                        ) { a in
                            PillChip(alignmentLabel(a), isSelected: titleAlignment == a) { titleAlignment = a }
                        }
                    }
                    Stepper("Pages: \(pageCount)", value: $pageCount, in: 0...4)
                    Stepper("Selected ID: \(selection)", value: $selection, in: 0...3)
                    Toggle("Reverse pages", isOn: $reversed)
                    Toggle("Custom header and footer", isOn: $customChrome)
                    Toggle("Large title font", isOn: $largeFont)
                    Toggle("Reduced-motion crossfade", isOn: $usesCrossfade)
                    LabeledContent("Peek width") { Slider(value: $peekWidth, in: 0...80) }
                    LabeledContent("Title gap") { Slider(value: $titleGap, in: 0...32) }
                    LabeledContent("Header spacing") { Slider(value: $headerSpacing, in: 0...32) }
                    Toggle("Override title inset", isOn: $usesInset)
                    LabeledContent("Title inset") { Slider(value: $leadingInset, in: 0...80) }
                    ColorPicker("Title", selection: $titleColor)
                    ColorPicker("Adjacent title", selection: $adjacentColor)
                    ColorPicker("Active indicator", selection: $activeColor)
                    ColorPicker("Inactive indicator", selection: $inactiveColor)
                    ColorPicker("Background", selection: $backgroundColor, supportsOpacity: true)
                    Toggle("Enable hint", isOn: $hintEnabled)
                    LabeledContent("Hint delay") { Slider(value: $hintDelay, in: 0...3) }
                    LabeledContent("Hint distance") { Slider(value: $hintDistance, in: 0...80) }
                    Toggle("Right-to-Left", isOn: $isRTL)
                        .toggleStyle(ThemeToggleStyle())
                }
            }

            // The component itself
            ShowcaseSection("Result") {
                ShowcasePagedPreview(
                    pages: reversed
                        ? Array(Self.pages.prefix(pageCount).reversed()) : Array(Self.pages.prefix(pageCount)),
                    selection: $selection, titleAlignment: titleAlignment,
                    indicatorStyle: indicatorStyle, customChrome: customChrome
                )
                .designPaginationStyle(
                    .init(
                        titleFont: largeFont ? theme.typography.largeTitle : nil,
                        titleColor: titleColor, adjacentTitleColor: adjacentColor,
                        background: AnyShapeStyle(backgroundColor),
                        indicatorActiveColor: activeColor, indicatorInactiveColor: inactiveColor,
                        peekDirection: peekDirection, peekWidth: peekWidth,
                        headerSpacing: headerSpacing, titleGap: titleGap,
                        titleLeadingPadding: usesInset ? leadingInset : nil,
                        reduceMotionUsesCrossfade: usesCrossfade
                    )
                )
                .designSwipeHint(.init(isEnabled: hintEnabled, delay: hintDelay, distance: hintDistance))
                .frame(height: 220)
                .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            }
        }
    }

    private func indicatorLabel(_ s: PaginationIndicatorStyle) -> String {
        switch s {
        case .dots: "Dots";
        case .bar: "Bar";
        case .hidden: "Hidden"
        }
    }
    private func peekLabel(_ d: PaginationPeekDirection) -> String {
        switch d {
        case .bidirectional: "Both";
        case .unidirectional: "Next only";
        case .none: "None"
        }
    }
    private func alignmentLabel(_ a: TitledPageTitleAlignment) -> String {
        switch a {
        case .automatic: "Auto"
        case .leading: "Leading"
        case .center: "Center"
        case .trailing: "Trailing"
        case .hidden: "Hidden"
        }
    }
}

/// A labeled row of configuration chips, wrapped in a `FlowLayout` so it
/// wraps onto multiple lines as needed.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff and update each row independently.
private struct PagedViewControlRow<Content: View>: View {
    let label: String
    @ViewBuilder let chips: Content

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            Text(label)
                .designTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)
            FlowLayout(spacing: theme.spacing.halfUnit) { chips }
        }
    }
}

/// A single demo page card shown inside the `TitledPageView` preview.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff and update each page independently.
private struct PagedViewPageCard: View {
    let page: PagedViewDetailView.Page

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            Image(systemName: page.symbol)
                .font(theme.typography.largeTitle)
                .foregroundStyle(theme.colors.primary)
            Text(page.summary)
                .designTextStyle(.body)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.twoUnits)
        .designCardSurface()
        .padding(.horizontal, theme.spacing.oneUnit)
    }
}

#Preview {
    ScrollView {
        PagedViewDetailView()
            .padding()
    }
}

private struct ShowcasePagedPreview: View {
    let pages: [PagedViewDetailView.Page]
    @Binding var selection: Int
    let titleAlignment: TitledPageTitleAlignment
    let indicatorStyle: PaginationIndicatorStyle
    let customChrome: Bool

    var body: some View {
        if customChrome {
            TitledPageView(pages, selection: $selection, title: \.title) { context in
                Text(context.currentTitle).designTextStyle(.headline)
            } footerContent: { context in
                HStack {
                    Button("Previous") { context.selectPage(context.activeIndex - 1) }
                    Text("\(context.activeIndex + 1) / \(context.pageCount)")
                    Button("Next") { context.selectPage(context.activeIndex + 1) }
                }
            } content: {
                PagedViewPageCard(page: $0)
            }
        } else {
            TitledPageView(
                pages, selection: $selection, title: \.title,
                titleAlignment: titleAlignment, indicatorStyle: indicatorStyle
            ) {
                PagedViewPageCard(page: $0)
            }
        }
    }
}
