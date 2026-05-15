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

Two SPM library products — add both to your target when you need views:

```swift
import DesignSystem   // tokens: spacing, radius, stroke, motion, colors, typography
import Components     // views and modifiers — depends on DesignSystem
```

Platforms: iOS 18+, macOS 15+, Mac Catalyst 18+. Swift language mode: 6 (strict concurrency).

## Theme Setup (required)

Apply once at the root of your view hierarchy; all child components inherit it via SwiftUI environment:

```swift
ContentView()
    .designTheme(DefaultDesignTheme())
```

To create a custom theme, conform a struct to `DesignTheme` (a `Sendable` protocol with six sub-protocol properties):

```swift
struct MyTheme: DesignTheme {
    var spacing: any DesignSpacing      // halfUnit … sixUnits (4 pt grid)
    var radius: any DesignRadius        // oneUnit … threeUnits, pill
    var stroke: any DesignStroke        // hairline, thin, regular, thick
    var motion: any DesignMotion        // minimumHitTarget, disabledOpacity, standardAnimation
    var colors: any DesignColorTheme    // primary, onPrimary, textPrimary/Secondary/Tertiary,
                                        // background, backgroundSecondary, container,
                                        // containerSecondary, border, separator,
                                        // error, onError, success, warning, disabled
    var typography: any DesignTypography // largeTitle, title, title2, title3,
                                         // headline, body, callout, subheadline,
                                         // footnote, caption, caption2,
                                         // button, control, field, badge
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
DesignButton("Label", role: .primary, isLoading: false) { /* action */ }
// roles: .primary (default) | .secondary | .tertiary | .destructive

// ViewBuilder label init
DesignButton(role: .secondary, isLoading: false, action: { }) {
    Label("Share", systemImage: "square.and.arrow.up")
}

// Apply design style to a native SwiftUI Button
Button("Label") { }.buttonStyle(DesignButtonStyle(role: .primary))
```

### Search Input

```swift
DesignSearchBar(
    text: $query,
    placeholder: "Search",        // default: "Search"
    isFocused: $isFocused,        // optional Binding<Bool>
    onSubmit: { /* action */ }    // optional
)
```

### Toggle

```swift
Toggle("Label", isOn: $isOn)
    .toggleStyle(DesignToggleStyle())
```

### Badge

```swift
DesignBadge("New")                       // standard (secondary container fill)
DesignBadge("Pro", isProminent: true)    // prominent (primary color fill)
```

### Filter Chip

```swift
DesignPillChip("Label", isSelected: isSelected) { /* action */ }
```

### Picker

```swift
// Item must conform to MenuPickerItem: Hashable & Identifiable, var title: String
MenuPicker(items: allItems, currentValue: $selected)

// Optional width change callback (useful for aligning adjacent controls)
MenuPicker(items: allItems, currentValue: $selected) { newWidth in
    pickerWidth = newWidth
}
```

### Container

```swift
DesignContainer(style: .card) { content }
// styles: .plain | .card (default) | .elevated (shadow) | .outlined
```

### Feedback States

```swift
DesignLoadingView()                           // spinner only
DesignLoadingView("Loading items…")           // spinner + message

DesignEmptyStateView(title: "No results")     // no action
DesignEmptyStateView(
    title: "No results",
    message: "Try a different search term.",
    systemImage: "magnifyingglass"
) {
    DesignButton("Clear search") { query = "" }
}
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
```

## Common Patterns

```swift
// Horizontal filter chip group
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: theme.spacing.oneUnit) {
        ForEach(filters) { filter in
            DesignPillChip(filter.label, isSelected: selectedFilter == filter) {
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
    DesignLoadingView("Fetching items…")
} else if items.isEmpty {
    DesignEmptyStateView(title: "Nothing here yet", systemImage: "tray") {
        DesignButton("Refresh") { load() }
    }
} else {
    List(items) { /* row */ }
}
```

## Do Not

- **Do not** import only `DesignSystem` and then use views — `Components` is a separate SPM product and must be added to your target explicitly.
- **Do not** access `theme.colors` or `theme.typography` outside `@MainActor` context — these properties are `@MainActor`-isolated and will produce concurrency errors.
- **Do not** skip `.designTheme()` — a fallback default exists, but it won't reflect your brand colors or custom fonts.
- **Do not** conform `MenuPickerItem` items with only `Identifiable` — the protocol also requires `Hashable`.
- **Do not** pass a `String` literal to the `DesignButton` `@ViewBuilder` initializer — use the convenience `init(_ title: String, role:isLoading:action:)` for text-only buttons.
