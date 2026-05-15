# AI-Assisted Integration

When you use Claude Code (or another AI assistant that reads CLAUDE.md files) in a project that depends on SwiftUIComponents, you can give the AI rich context about the library by adding a snippet to your project's own CLAUDE.md.

**Why this is necessary:** SwiftUIComponents resolves into `.build/checkouts/` when added as an SPM dependency. Claude Code does not auto-load CLAUDE.md files inside package checkouts — only files in your own project tree. Pasting the snippet below into your project's CLAUDE.md closes that gap.

## How to Use

1. Open (or create) `CLAUDE.md` in your project's root directory.
2. Copy the entire fenced snippet below and paste it in.
3. Optionally trim sections for products you aren't using.

---

```markdown
## Dependency: SwiftUIComponents

Two SPM library products — add both to your target when you need views:

    import DesignSystem   // tokens: spacing, radius, stroke, motion, colors, typography
    import Components     // views and modifiers — depends on DesignSystem

Platforms: iOS 18+, macOS 15+, Mac Catalyst 18+. Swift language mode: 6 (strict concurrency).

### Theme Setup (required)

Apply once at the root of your view hierarchy; all child components inherit it via SwiftUI environment:

    ContentView()
        .designTheme(DefaultDesignTheme())

To create a custom theme, conform a struct to `DesignTheme` and provide six sub-protocol properties:
`spacing` (DesignSpacing), `radius` (DesignRadius), `stroke` (DesignStroke),
`motion` (DesignMotion), `colors` (DesignColorTheme), `typography` (DesignTypography).

### Reading Tokens in Custom Views

    @Environment(\.designTheme) var theme
    theme.spacing.twoUnits    // CGFloat
    theme.colors.primary      // Color  (@MainActor)
    theme.typography.body     // Font   (@MainActor)

All `colors` and `typography` access is @MainActor — use only from View.body or @MainActor functions.

### Component Reference

Buttons:
    DesignButton("Label", role: .primary, isLoading: false) { }
    // roles: .primary (default) | .secondary | .tertiary | .destructive
    DesignButton(role: .secondary, action: { }) { Label("Share", systemImage: "square.and.arrow.up") }
    Button("Label") { }.buttonStyle(DesignButtonStyle(role: .primary))

Search:
    DesignSearchBar(text: $query, placeholder: "Search", isFocused: $isFocused, onSubmit: { })

Toggle:
    Toggle("Label", isOn: $isOn).toggleStyle(DesignToggleStyle())

Badge:
    DesignBadge("New")                      // standard
    DesignBadge("Pro", isProminent: true)   // primary color fill

Filter chip:
    DesignPillChip("Label", isSelected: isSelected) { /* action */ }

Picker (item must conform to MenuPickerItem: Hashable & Identifiable, var title: String):
    MenuPicker(items: allItems, currentValue: $selected)
    MenuPicker(items: allItems, currentValue: $selected) { newWidth in pickerWidth = newWidth }

Container:
    DesignContainer(style: .card) { content }
    // styles: .plain | .card (default) | .elevated (shadow) | .outlined

Feedback:
    DesignLoadingView()
    DesignLoadingView("Loading…")
    DesignEmptyStateView(title: "No results")
    DesignEmptyStateView(title: "No results", message: "Try again.", systemImage: "magnifyingglass") {
        DesignButton("Clear") { query = "" }
    }

Modifiers:
    .designCardSurface()                    // rounded card with border
    .designCardSurface(showStroke: false)   // card without border
    .designCapsuleSurface()                 // pill surface
    .designCapsuleSurface(isSelected: true) // selected state
    .designInputSurface()                   // text field background
    .designTextStyle(.headline)             // font + color from theme
    // text roles: .title | .headline | .body | .secondary | .caption | .error

### Common Patterns

Filter chip group:
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: theme.spacing.oneUnit) {
            ForEach(filters) { f in
                DesignPillChip(f.label, isSelected: selected == f) { selected = f }
            }
        }
        .padding(.horizontal, theme.spacing.twoUnits)
    }

Themed text field:
    TextField("Email", text: $email)
        .padding(theme.spacing.oneAndHalfUnits)
        .designInputSurface()

Loading / empty / content:
    if isLoading { DesignLoadingView("Fetching…") }
    else if items.isEmpty { DesignEmptyStateView(title: "Nothing here yet", systemImage: "tray") {
        DesignButton("Refresh") { load() }
    }}
    else { List(items) { /* row */ } }

### Do Not

- Don't import only `DesignSystem` when you need views — `Components` is a separate SPM product.
- Don't access `theme.colors` or `theme.typography` outside @MainActor — they are @MainActor-isolated.
- Don't skip `.designTheme()` — a default exists but won't match your brand.
- Don't conform `MenuPickerItem` items with only `Identifiable` — `Hashable` is also required.
- Don't pass a String literal to DesignButton's @ViewBuilder init — use the String convenience init.
```

---

## Section Reference

| Section | Why it matters |
|---|---|
| **Package identity** | Prevents the AI from suggesting wrong import names or assuming UIKit availability |
| **Theme setup** | Without this, the AI may tell you to skip `.designTheme()` and get a mis-styled UI |
| **Reading tokens** | The `@MainActor` callout prevents concurrency errors in Swift 6 projects |
| **Component reference** | Gives the AI exact initializer signatures so it generates code that compiles |
| **Common patterns** | Idiomatic examples prevent the AI from inventing plausible-but-wrong usage |
| **Do not** | Anti-patterns that produce non-compiling or poorly-branded results |
