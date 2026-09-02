# Modifiers

The theme-aware `View` modifiers `Components` adds, and when to reach for each.

## Overview

Every styling concern that more than one component shares — card and capsule
surfaces, chip metrics, text roles, notice cards, the Liquid Glass fallback, the
skeleton shimmer — is exposed as a `design*` modifier on `View`. They read the
active `Theme` from the environment and resolve spacing, radius, colour, and
typography from its tokens, so a re-themed app restyles without touching call
sites.

Prefer these over a hand-rolled equivalent. A local `RoundedRectangle`
background with a literal corner radius drifts from the theme the moment a token
changes; `designCardSurface()` does not. The same applies to chip padding,
scrim colours, and text styling.

> Note: These are extensions on `SwiftUI.View`. DocC is built with
> `--exclude-extended-types`, so they have no generated symbol pages — this
> article is their reference. The consumer-facing copy lives in
> [`docs/ai-integration.md`](https://github.com/maniramezan/SwiftUIComponents/blob/main/docs/ai-integration.md).

## Surfaces

- term `designCardSurface(showStroke: Bool = true)`:
  Rounded card fill with an optional hairline border. Padding and radius come
  from the theme. Pass `showStroke: false` for a borderless card.
- term `designCapsuleSurface(isSelected: Bool = false)`:
  Pill-shaped fill for chips and tags. `isSelected` swaps to the selected
  treatment. Combine with ``PillMetrics`` / `designPillMetrics()` for hit-target
  sizing.
- term `designInputSurface()`:
  Text-field background — the fill and corner radius used by ``SearchBar`` and
  themed `TextField`s.
- term `designSelectableCardSurface(isSelected: Bool, cornerRadius: CGFloat? = nil)`:
  Card surface that carries a selected state (fill plus selection outline). Pass
  `cornerRadius` to override the theme radius for one call.
- term `designNoticeCard(background: Color, cornerRadius: CGFloat? = nil, padding: CGFloat? = nil)`:
  Full-width, padded, rounded container for inline notice, banner, and error
  cards. Defaults: `spacing.twoUnits` padding, `radius.oneAndHalfUnits` corner.
  See ``NoticeCard``.

```swift
Text("Saved")
    .designCardSurface()

Text("Offline")
    .designNoticeCard(background: theme.colors.error)
```

## Chips

- term `designPillMetrics(horizontalPadding: CGFloat? = nil)`:
  Capsule-pill padding (`spacing.oneUnit` vertical), the minimum hit-target
  height, and a capsule content shape. Pair with `designCapsuleSurface(...)`
  rather than hand-rolling chip backgrounds. See ``PillMetrics``.

## Typography

- term `designTextStyle(_ role: TextRole)`:
  Font and foreground colour for a semantic ``TextRole`` — `.title`,
  `.headline`, `.body`, `.secondary`, `.caption`, `.error`. See ``TypeStyle``.

```swift
Text("Section")
    .designTextStyle(.headline)
```

For a full type-scale rung rather than a semantic role, render a ``DesignText`` with a
``TypographySlot`` — it applies the matching `Typography` font and nothing else, so the
call site never names a raw `Font`:

```swift
DesignText("Section", slot: .headlineSemibold)
```

## Feedback

- term `designGhostShimmer()`:
  Sweeps a soft highlight band across skeleton content so ``GhostLoadingBlock``
  placeholders read as in-progress rather than frozen. Apply once at the root of
  a skeleton layout, not per block. Static under Reduce Motion; the
  `\.isGhostShimmerDisabled` environment value forces the static form for
  deterministic snapshots.
- term `toast(_:role:isPresented:edge:duration:action:)` and `toast(isPresented:content:)`:
  Presents a transient ``ToastView`` over a full-bleed parent. Top/bottom
  placement is safe-area-aware, honours Reduce Motion, and swipe-to-dismiss is
  always on.

```swift
VStack {
    GhostLoadingBlock(width: 160, height: 16)
    GhostLoadingBlock(height: 88)
}
.designGhostShimmer()
```

## Adaptive (Liquid Glass)

Both honour the `UIDesignRequiresCompatibility` Info.plist key — when it is
`true`, the fallback is always used regardless of OS version.

- term `designAdaptiveSurface(tint: Color? = nil, interactive: Bool = false, cornerRadius: CGFloat? = nil)`:
  Glass surface on iOS/macOS 26+, `.ultraThinMaterial` below. `tint` colours the
  glass; `interactive` lets it respond to pointer and press.
- term `designAdaptiveButtonStyle(prominent: Bool = false)`:
  `.glass` / `.glassProminent` button style on 26+, `.bordered` /
  `.borderedProminent` below.

## Pagination

Both target ``TitledPageView`` in the hierarchy below them.

- term `designPaginationStyle(_ style: PaginationStyle)`:
  Overrides per-call pagination styling. Each non-`nil` property of `style` wins
  over the theme; `nil` properties keep resolving from the `Theme`.
- term `designSwipeHint(_ config: TitledPageSwipeHintConfig)` / `designSwipeHint(enabled: Bool)`:
  Tunes or disables the automatic swipe-hint animation. The `enabled:` form is
  shorthand for toggling it without touching timing or distance.

## Topics

### Supporting types

- ``TextRole``
- ``TypeStyle``
- ``PillMetrics``
- ``NoticeCard``
- ``PaginationStyle``
- ``TitledPageSwipeHintConfig``
