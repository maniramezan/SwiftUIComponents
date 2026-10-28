import DesignSystem
import SwiftUI

struct TitledPageViewHeader<ID: Hashable>: View {
    let resolved: ResolvedPaginationStyle
    let entries: [TitledPageTitle<ID>]
    let progress: CGFloat
    let activeIndex: Int
    let viewportWidth: CGFloat
    let reduceMotion: Bool
    let onJump: (Int) -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        let metrics = TitledPageViewMetrics(viewportWidth: viewportWidth, style: resolved, reduceMotion: reduceMotion)
        let crossfades = reduceMotion && resolved.reduceMotionUsesCrossfade
        Group {
            if crossfades || resolved.peekDirection == .none {
                ZStack {
                    if entries.indices.contains(activeIndex) {
                        Text(entries[activeIndex].title)
                            .id(entries[activeIndex].id)
                            .transition(.opacity)
                            .font(resolved.titleFont)
                            .foregroundStyle(resolved.titleColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }
                .frame(maxWidth: .infinity, alignment: crossfades ? .center : slotAlignment)
                .animation(theme.motion.animation(reducingMotion: reduceMotion), value: activeIndex)
            } else {
                HStack(spacing: resolved.titleGap) {
                    ForEach(entries) { entry in
                        Button {
                            onJump(entry.index)
                        } label: {
                            Text(entry.title)
                                .font(resolved.titleFont)
                                .foregroundStyle(
                                    entry.index == activeIndex ? resolved.titleColor : resolved.adjacentTitleColor
                                )
                                .opacity(entry.index == activeIndex ? 1 : 0.6)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                                .frame(width: metrics.slotWidth, alignment: slotAlignment)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, resolved.titleLeadingPadding ?? metrics.leadingPadding)
                .offset(x: TitledPageViewMath.headerOffset(progress: progress, stride: metrics.slotStride))
                .frame(width: viewportWidth, alignment: .leading)
                .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var slotAlignment: Alignment {
        switch TitledPageViewMath.titleLayout(for: resolved.titleAlignment, fallbackDirection: resolved.peekDirection) {
        case .trailing: .trailing
        case .center: .center
        default: .leading
        }
    }
}

@MainActor
private func headerPreviewStyle(theme: any Theme) -> ResolvedPaginationStyle {
    ResolvedPaginationStyle(
        titleFont: theme.typography.title2,
        titleColor: theme.colors.textPrimary,
        adjacentTitleColor: theme.colors.textSecondary,
        background: nil,
        indicatorActiveColor: theme.colors.primary,
        indicatorInactiveColor: theme.colors.disabled,
        peekDirection: .bidirectional,
        titleAlignment: .automatic,
        peekWidth: theme.spacing.fiveUnits,
        headerSpacing: theme.spacing.twoUnits,
        titleGap: theme.spacing.twoUnits,
        reduceMotionUsesCrossfade: true,
        titleLeadingPadding: nil
    )
}

private let _headerPreviewTitles = ["Best of 2025", "Spotlight: Health", "Travel Companions"]

#Preview("Snapped to first page") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: headerPreviewStyle(theme: theme),
            entries: TitledPageCollection(_headerPreviewTitles, id: \.self, title: \.self).header,
            progress: 0,
            activeIndex: 0,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Mid-swipe between pages 1 and 2") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: headerPreviewStyle(theme: theme),
            entries: TitledPageCollection(_headerPreviewTitles, id: \.self, title: \.self).header,
            progress: 1.4,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Center alignment – snapped to page 1") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: {
                let s = headerPreviewStyle(theme: theme)
                return ResolvedPaginationStyle(
                    titleFont: s.titleFont,
                    titleColor: s.titleColor,
                    adjacentTitleColor: s.adjacentTitleColor,
                    background: s.background,
                    indicatorActiveColor: s.indicatorActiveColor,
                    indicatorInactiveColor: s.indicatorInactiveColor,
                    peekDirection: .bidirectional,
                    titleAlignment: .center,
                    peekWidth: s.peekWidth,
                    headerSpacing: s.headerSpacing,
                    titleGap: s.titleGap,
                    reduceMotionUsesCrossfade: s.reduceMotionUsesCrossfade,
                    titleLeadingPadding: s.titleLeadingPadding
                )
            }(),
            entries: TitledPageCollection(_headerPreviewTitles, id: \.self, title: \.self).header,
            progress: 1,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Unidirectional – dimmed previous title") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: {
                let s = headerPreviewStyle(theme: theme)
                return ResolvedPaginationStyle(
                    titleFont: s.titleFont,
                    titleColor: s.titleColor,
                    adjacentTitleColor: s.adjacentTitleColor,
                    background: s.background,
                    indicatorActiveColor: s.indicatorActiveColor,
                    indicatorInactiveColor: s.indicatorInactiveColor,
                    peekDirection: .unidirectional,
                    titleAlignment: .leading,
                    peekWidth: s.peekWidth,
                    headerSpacing: s.headerSpacing,
                    titleGap: s.titleGap,
                    reduceMotionUsesCrossfade: s.reduceMotionUsesCrossfade,
                    titleLeadingPadding: s.titleLeadingPadding
                )
            }(),
            entries: TitledPageCollection(_headerPreviewTitles, id: \.self, title: \.self).header,
            progress: 1,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}
