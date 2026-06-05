# SwiftUIComponents — Claude Code Context

This file serves two audiences:

- **Contributors** working inside this repository — see the imported guidelines below.
- **Consumers** who depend on this package via SPM — copy the snippet at the bottom into your own project's CLAUDE.md so your AI assistant understands the library's API.

@AGENTS.md

---

## Consumer CLAUDE.md Snippet

> Copy everything from the opening `## Dependency` fence to the end of the `## Do not` block
> into your own project's CLAUDE.md. Customize as needed.

---

## Dependency: SwiftUIComponents

SwiftUIComponents currently ships three SwiftPM library products:

- `DesignSystem`: design tokens and theming primitives.
- `Components`: reusable SwiftUI views and modifiers. Depends on `DesignSystem`.
- `ComponentShowcase`: demo/reference screens used by this package. Do not import it into production app targets.

For application code, import the first two:

```swift
import DesignSystem   // tokens: spacing, radius, stroke, motion, colors, typography
import Components     // views and modifiers — depends on DesignSystem
```

Platforms: iOS 18+, macOS 15+, Mac Catalyst 18+. Swift language mode: 6 (strict concurrency).

## Architecture Decisions

- `DesignSystem` owns token protocols, default token implementations, and theme environment wiring.
- `Components` owns reusable UI primitives, view modifiers, and production-facing APIs.
- `ComponentShowcase` is a demo layer for previews, examples, and exploration. Never treat it as a reusable dependency for app features.
- Apply `.designTheme(...)` near the root and let views read tokens from the environment.
- When a pattern becomes reusable, move it into `Components` instead of duplicating showcase code in apps.

## Theme Setup (required)

Apply once at the root of your view hierarchy; all child components inherit it via SwiftUI environment:

```swift
ContentView()
    .designTheme(DefaultTheme())
```

To create a custom theme, conform a struct to `Theme` (a `Sendable` protocol with six properties):

```swift
struct MyTheme: Theme {
    var spacing: any Spacing         // halfUnit … sixUnits (4/8-point scale)
    var radius: any Radius           // oneUnit, oneAndHalfUnits, twoUnits, threeUnits, pill
    var stroke: any Stroke           // hairline, thin, regular, thick
    var motion: any Motion           // minimumHitTarget, disabledOpacity, standardAnimation
    var colors: any ColorTheme       // background, container, primary, textPrimary, error, etc.
    var typography: any Typography   // largeTitle, title, title2, headline, body, field, badge, etc.
}
```

## Reading Tokens in Custom Views

```swift
@Environment(\.designTheme) var theme

// then in body:
theme.spacing.twoUnits        // CGFloat
theme.colors.primary          // Color  (@MainActor)
theme.typography.body         // Font   (@MainActor)
```

All `colors` and `typography` access is `@MainActor` — use only from `View.body` or `@MainActor` functions.

## Component Reference

### Buttons (`import Components`)

```swift
// Convenience text init (most common)
ThemeButton("Label", role: .primary, isLoading: false) { /* action */ }
// roles: .primary (default) | .secondary | .tertiary | .destructive

// ViewBuilder label init
ThemeButton(role: .secondary, isLoading: false, action: { }) {
    Label("Share", systemImage: "square.and.arrow.up")
}

// Apply design style to a native SwiftUI Button
Button("Label") { }.buttonStyle(ThemeButtonStyle(role: .primary))
```

### Search Input

```swift
SearchBar(
    text: $query,
    placeholder: "Search",        // default: "Search"
    isFocused: $isFocused,        // optional Binding<Bool>
    onSubmit: { /* action */ }    // optional
)
```

### Toggle

```swift
Toggle("Label", isOn: $isOn)
    .toggleStyle(ThemeToggleStyle())
```

### Badge

```swift
Badge("New")                       // standard (secondary container fill)
Badge("Pro", isProminent: true)    // prominent (primary color fill)
```

### Filter Chip

```swift
PillChip("Label", isSelected: isSelected) { /* action */ }
```

### Picker

```swift
// Item must conform to MenuPickerItem: Hashable & Identifiable, var title: String
MenuPicker(items: allItems, currentValue: $selected)

// Optional width change callback (useful for aligning adjacent controls)
MenuPicker(items: allItems, currentValue: $selected, onWidthChange: { newWidth in
    pickerWidth = newWidth
})
```

### Selection List

A themed selection list for presenting inside a `.sheet` or drawer, or inline, with optional
search and inline two-level disclosure. Supports single-choice and multiple-choice.
Rows come from a `SelectionNode` tree: a node with no children is a leaf that selects
on tap; a node with children expands inline to reveal them. Controlled and
content-only — it reflects the selection you pass and reports taps via a callback;
it never mutates selection or dismisses itself. Search filters across both levels;
selected rows show a checkmark and a collapsed parent lists its selected children as
its subtitle.

```swift
let nodes: [SelectionNode<String>] = [
    .init(id: "water", title: "Water"),                   // leaf
    .init(id: "fruit", title: "Fruit", children: [        // expands inline
        .init(id: "apple", title: "Apple"),
        .init(id: "banana", title: "Banana"),
    ]),
]

// Single choice — replace selection and dismiss in the callback
.sheet(isPresented: $isPresented) {
    SelectionListView(title: "Category", nodes: nodes, selectedID: choice, isSearchable: true) { id in
        choice = id
        isPresented = false
    }
}

// Multiple choice — toggle membership; the sheet stays open
.sheet(isPresented: $isPresented) {
    SelectionListView(title: "Categories", nodes: nodes, selectedIDs: choices) { id in
        choices.formSymmetricDifference([id])
    }
}
```

To embed the same list inline in your own screen (no NavigationStack / dismiss button —
e.g. a full-screen onboarding step with its own header and button), use
`SelectionListContentView` with the same params minus `title`:

```swift
SelectionListContentView(nodes: nodes, selectedID: choice, isSearchable: true) { choice = $0 }
```

### Segmented Picker

A horizontally laid out single-selection picker. Sizes to fit its segments
when there is room; falls back to a horizontally scrolling row when they
overflow. In the scrolling layout, the scrollable edges are veiled by a
trough-colored gradient so users can see that more segments exist off-screen.
The active segment auto-scrolls into view when `selection` changes.

```swift
// Item must conform to MenuPickerItem (same as MenuPicker).
SegmentedPicker(items: Filter.allCases, selection: $filter)

// fillEqually — all segments same width, filling available space.
SegmentedPicker(items: Filter.allCases, selection: $filter, sizing: .fillEqually)

// fillProportionally — fills available width, segments proportional to intrinsic content size.
SegmentedPicker(items: Filter.allCases, selection: $filter, sizing: .fillProportionally)

// Badge overlay — pass a closure returning a String? per item.
// Non-empty string → labeled badge; "" → dot indicator; nil → no badge.
SegmentedPicker(items: Filter.allCases, selection: $filter) { item in
    item == .inbox ? "3" : nil
}

// Custom label per segment (icon + text, etc.). The closure receives the item
// and an isActive flag; the picker already flips foreground color and fades in
// the primary capsule for the active segment, so most callers ignore the flag.
SegmentedPicker(items: tabs, selection: $tab) { tab, _ in
    HStack(spacing: 4) {
        Image(systemName: tab.systemImage)
        Text(tab.title)
    }
}

// Custom label with badge
SegmentedPicker(items: tabs, selection: $tab, badge: { tab in tab.unreadCount > 0 ? "\(tab.unreadCount)" : nil }) { tab, _ in
    Text(tab.title)
}
```

### Container

```swift
Container(style: .card) { content }
// styles: .plain | .card (default) | .elevated (shadow) | .outlined
```

### Feedback States

```swift
LoadingView()                           // spinner only
LoadingView("Loading items…")           // spinner + message

EmptyStateView(title: "No results") { EmptyView() }
EmptyStateView(
    title: "No results",
    message: "Try a different search term.",
    systemImage: "magnifyingglass"
) {
    ThemeButton("Clear search") { query = "" }
}

ErrorBanner("Something went wrong.")
ErrorSection(message: "Could not load data.")

AsyncContentView(state: viewModel.profileState) { profile in
    ProfileDetail(profile)
} loadingContent: {
    LoadingView("Loading profile")
} errorContent: { error in
    ErrorBanner(error.localizedDescription)
}

ChatBubbleView(role: .assistant, content: "Hello! How can I help?")
TypingIndicatorBubbleView()
```

### View Modifiers

```swift
.designCardSurface()                  // rounded card background with border
.designCardSurface(showStroke: false) // card without border
.designCapsuleSurface()               // pill-shaped surface
.designCapsuleSurface(isSelected: true) // selected state (primary fill)
.designInputSurface()                 // text field background (secondary container)
.designTextStyle(.headline)           // sets font + foreground color from active theme
// roles: .title | .headline | .body | .secondary | .caption | .error

// TitledPageView swipe hint (plays automatically by default)
.designSwipeHint(.disabled)              // suppress entirely
.designSwipeHint(enabled: false)         // shorthand for .disabled
.designSwipeHint(.init(delay: 1.0))      // fire later (default 0.6 s)
.designSwipeHint(.init(distance: 60))    // peek 60 pt (default: theme.spacing.fiveUnits)
// Replay the hint in previews/sample apps by changing the view's .id:
// Button("Replay") { hintToken = UUID() }
// TitledPageView(...).id(hintToken)
```

## Common Patterns

```swift
// Horizontal filter chip group
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: theme.spacing.oneUnit) {
        ForEach(filters) { filter in
            PillChip(filter.label, isSelected: selectedFilter == filter) {
                selectedFilter = filter
            }
        }
    }
    .padding(.horizontal, theme.spacing.twoUnits)
}

// Themed text field
TextField("Email", text: $email)
    .padding(theme.spacing.oneAndHalfUnits)
    .designInputSurface()

// Loading / empty / content conditional
if isLoading {
    LoadingView("Fetching items…")
} else if items.isEmpty {
    EmptyStateView(title: "Nothing here yet", systemImage: "tray") {
        ThemeButton("Refresh") { load() }
    }
} else {
    List(items) { /* row */ }
}
```

## Accessibility & Localization

- Components include VoiceOver support out of the box: accessibility labels, traits, hidden decorative elements, Reduce Motion handling, and adjustable/scroll actions on the paged and segmented controls.
- The package localizes only its **own** chrome — the dismiss button, loading/typing announcements, error prefix, and paginator/clear-search labels — via a String Catalog resolved from `Bundle.module`. English (`en`) is the only bundled locale today.
- **Content you pass in is rendered verbatim and is your app's responsibility to localize**: `ThemeButton` titles, `SearchBar` placeholder, `SelectionNode` titles, and the `ConfirmToolbarButton` accessibility label. Pass already-localized values (e.g. `String(localized:)`).

## Do Not

- **Do not** import only `DesignSystem` and then use views — `Components` is a separate SPM product and must be added to your target explicitly.
- **Do not** import `ComponentShowcase` into production targets — it is a demo/reference layer.
- **Do not** access `theme.colors` or `theme.typography` outside `@MainActor` context — these properties are `@MainActor`-isolated and will produce concurrency errors.
- **Do not** skip `.designTheme()` — a fallback default exists, but it won't reflect your brand colors or custom fonts.
- **Do not** conform `MenuPickerItem` items with only `Identifiable` — the protocol also requires `Hashable`.
- **Do not** put reusable production UI in `ComponentShowcase` — move it into `Components`.
- **Do not** pass a `String` literal to the `ThemeButton` `@ViewBuilder` initializer — use the convenience `init(_ title: String, role:isLoading:action:)` for text-only buttons.
- **Do not** wrap `SegmentedPicker` in a parent that constrains its width to the segments' intrinsic size (an `HStack` next to a non-flexible sibling, a `Form` row). The scroll-and-fade behavior requires a parent that proposes a finite, potentially-narrower width — otherwise the picker just grows to fit every segment and never scrolls.
- **Do not** pass unlocalized literals as component content (titles, placeholders, accessibility labels) — these are rendered verbatim, so localize them on your side before passing them in.
