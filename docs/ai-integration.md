# AI-Assisted Integration

When you use Claude Code (or another AI assistant that reads `CLAUDE.md` files) in a project that depends on SwiftUIComponents, you can give the AI accurate context about the library by adding a snippet to your project's own `CLAUDE.md`.

**Why this is necessary:** SwiftUIComponents resolves into `.build/checkouts/` when added as an SPM dependency. Claude Code does not auto-load `CLAUDE.md` files inside package checkouts, only files in your own project tree. Pasting the snippet below into your project's `CLAUDE.md` closes that gap.

## How to Use

1. Open or create `CLAUDE.md` in your project's root directory.
2. Copy the entire fenced snippet below and paste it in.
3. Optionally trim sections for products you aren't using.

---

```markdown
## Dependency: SwiftUIComponents

SwiftUIComponents currently ships three SwiftPM library products:

- `DesignSystem`: design tokens and theming primitives.
- `Components`: reusable SwiftUI views and modifiers. Depends on `DesignSystem`.
- `ComponentShowcase`: demo/reference screens used by the package itself. Do not depend on this from production app targets.

For application code, import the first two:

    import DesignSystem   // tokens: spacing, radius, stroke, motion, colors, typography
    import Components     // views and modifiers — depends on DesignSystem

Platforms: iOS 18+, macOS 15+, Mac Catalyst 18+. Swift language mode: 6 (strict concurrency).

### Package Architecture Decisions

- `DesignSystem` owns tokens and theme protocols. Keep product branding and token definitions here.
- `Components` owns reusable UI primitives and view modifiers. Shared app UI should live here, not in `ComponentShowcase`.
- `ComponentShowcase` is for demos, previews, and exploration only. Do not import it into shipping app code.
- Apply `.designTheme(...)` once near the root of a feature or app. Components read the active theme from the environment.
- Prefer composing with existing components and modifiers before creating app-local lookalikes.

### Theme Setup (required)

Apply once at the root of your view hierarchy; all child components inherit it via SwiftUI environment:

    ContentView()
        .designTheme(DefaultTheme())

To create a custom theme, conform a struct to `Theme` and provide six properties:
`spacing` (`Spacing`), `radius` (`Radius`), `stroke` (`Stroke`),
`motion` (`Motion`), `colors` (`ColorTheme`), and `typography` (`Typography`).

### Reading Tokens in Custom Views

    @Environment(\.designTheme) var theme
    theme.spacing.twoUnits    // CGFloat
    theme.colors.primary      // Color  (@MainActor)
    theme.colors.segmentUnselectedBackground // Color (@MainActor)
    theme.typography.body     // Font   (@MainActor)

All `colors` and `typography` access is @MainActor — use only from View.body or @MainActor functions.

### Component Reference

Buttons:
    ThemeButton("Label", role: .primary, isLoading: false) { }
    // roles: .primary (default) | .secondary | .tertiary | .destructive
    ThemeButton(role: .secondary, action: { }) { Label("Share", systemImage: "square.and.arrow.up") }
    Button("Label") { }.buttonStyle(ThemeButtonStyle(role: .primary))

Search:
    SearchBar(text: $query, placeholder: "Search", isFocused: $isFocused, onSubmit: { })

Toggle:
    Toggle("Label", isOn: $isOn).toggleStyle(ThemeToggleStyle())

Badge:
    Badge("New")                    // standard
    Badge("Pro", isProminent: true) // primary color fill

Filter chip:
    PillChip("Label", isSelected: isSelected) { /* action */ }

Picker (item must conform to MenuPickerItem: Hashable & Identifiable, var title: String):
    MenuPicker(items: allItems, currentValue: $selected)
    MenuPicker(items: allItems, currentValue: $selected, onWidthChange: { newWidth in pickerWidth = newWidth })

Selection list (for `.sheet`/drawer or inline; single- or multiple-choice; rows are a SelectionNode<ID> tree — leaf nodes select on tap, parent nodes expand inline to reveal children; node has id, title, optional subtitle/leadingGlyph, children; controlled + content-only — you present it and update selection/dismiss in the callback; isSearchable filters both levels, case-insensitive):
    let nodes: [SelectionNode<String>] = [
        .init(id: "water", title: "Water"),
        .init(id: "fruit", title: "Fruit", children: [
            .init(id: "apple", title: "Apple"),
        ]),
    ]
    // Single choice:
    SelectionListView(title: "Category", nodes: nodes, selectedID: choice, isSearchable: true) { id in
        choice = id; isPresented = false
    }
    // Multiple choice (toggle; stays open):
    SelectionListView(title: "Categories", nodes: nodes, selectedIDs: choices) { id in
        choices.formSymmetricDifference([id])
    }
    // Inline embed (no NavigationStack/dismiss — own-screen use), same params minus title:
    SelectionListContentView(nodes: nodes, selectedID: choice, isSearchable: true) { choice = $0 }

Segmented picker (horizontal, single-selection; scrolls with fading edges when overflowing; auto-scrolls active segment into view):
    SegmentedPicker(items: Filter.allCases, selection: $filter)
    SegmentedPicker(items: tabs, selection: $tab) { tab, _ in
        HStack { Image(systemName: tab.systemImage); Text(tab.title) }
    }

Container:
    Container(style: .card) { content }
    // styles: .plain | .card (default) | .elevated (shadow) | .outlined

Flip card (two-sided flashcard; tap or VoiceOver "Flip" action toggles it):
    FlipCard {                               // self-managing — tracks its own flipped state
        Text("Bonjour")
    } back: {
        Text("Hello")
    }
    FlipCard(initiallyFaceUp: false, axis: .vertical) { front } back: { back }
    FlipCard(isFaceUp: $isFaceUp) { front } back: { back }   // controlled — drive the face externally
    // axis: .horizontal (default, sweeps left/right) | .vertical (sweeps top/bottom)
    // Each face is wrapped in a card surface; Reduce Motion replaces the 3D flip with a cross-fade.

Feedback:
    LoadingView()
    LoadingView("Loading…")
    EmptyStateView(title: "No results") { EmptyView() }
    EmptyStateView(title: "No results", message: "Try again.", systemImage: "magnifyingglass") {
        ThemeButton("Clear") { query = "" }
    }
    ErrorBanner("Something went wrong.")
    ErrorSection(message: "Could not load data.")

Toast (transient overlay; roles: .info | .success | .warning | .error):
    ToastView("Saved", role: .success)               // standalone card
    ToastView("Item deleted", role: .info, action: .init("Undo") { restore() })
    .toast("Saved", role: .success, isPresented: $showToast)            // bottom, auto-dismiss 3s
    .toast("Upload failed", role: .error, isPresented: $showError, edge: .top, duration: .seconds(5))
    .toast("Item deleted", role: .info, isPresented: $showToast,
           action: .init("Undo") { restore() })                         // actions persist until dismissed
    .toast(isPresented: $showToast) { ToastView("Custom", role: .info) } // custom content
    // Apply .toast to a full-bleed parent (it anchors an overlay); honors Reduce Motion; swipe-to-dismiss always on.
    // A11y: announces to VoiceOver on appear and supports the escape (two-finger scrub) gesture to dismiss.

Async state container:
    AsyncContentView(state: profileState) { profile in
        ProfileView(profile: profile)
    } loadingContent: {
        LoadingView("Loading profile")
    } errorContent: { error in
        ErrorBanner(error.localizedDescription)
    }

Chat:
    ChatBubbleView(role: .user, content: "Hello")
    ChatBubbleView(role: .assistant, content: "Hi there")
    TypingIndicatorBubbleView()

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
                PillChip(f.label, isSelected: selected == f) { selected = f }
            }
        }
        .padding(.horizontal, theme.spacing.twoUnits)
    }

Themed text field:
    TextField("Email", text: $email)
        .padding(theme.spacing.oneAndHalfUnits)
        .designInputSurface()

Loading / empty / content:
    if isLoading { LoadingView("Fetching…") }
    else if items.isEmpty { EmptyStateView(title: "Nothing here yet", systemImage: "tray") {
        ThemeButton("Refresh") { load() }
    }}
    else { List(items) { /* row */ } }

Use the showcase for reference, not reuse:
    // Good: copy interaction patterns from ComponentShowcase into app code using Components APIs.
    // Avoid: importing ComponentShowcase into the app target.

### Accessibility & Localization

- Components include VoiceOver support out of the box (labels, traits, hidden decorations, Reduce Motion, adjustable/scroll actions on paged + segmented controls).
- The package localizes only its own chrome (dismiss button, loading/typing announcements, error prefix, paginator + clear-search labels) via a String Catalog in `Bundle.module`; English is the only bundled locale today.
- Content you pass in is rendered verbatim and is your app's responsibility to localize: `ThemeButton` titles, `SearchBar` placeholder, `SelectionNode` titles, `ConfirmToolbarButton` accessibility label. Pass already-localized values (e.g. `String(localized:)`).

### Do Not

- Don't import only `DesignSystem` when you need views — `Components` is a separate SPM product.
- Don't import `ComponentShowcase` into production targets — it is a demo/reference layer.
- Don't access `theme.colors` or `theme.typography` outside @MainActor — they are @MainActor-isolated.
- Don't skip `.designTheme()` — a default exists but won't match your brand.
- Don't conform `MenuPickerItem` items with only `Identifiable` — `Hashable` is also required.
- Don't put reusable shipping components in the showcase target — promote them into `Components` first.
- Don't pass a String literal to ThemeButton's @ViewBuilder init — use the String convenience init.
- Don't pass unlocalized literals as component content (titles, placeholders, accessibility labels) — these are rendered verbatim, so localize them on your side.
```

---

## Section Reference

| Section | Why it matters |
|---|---|
| **Package identity** | Prevents the AI from suggesting wrong import names or assuming UIKit availability |
| **Architecture decisions** | Keeps the AI from putting production code in `ComponentShowcase` or importing the wrong product |
| **Theme setup** | Without this, the AI may tell you to skip `.designTheme()` and get a mis-styled UI |
| **Reading tokens** | The `@MainActor` callout prevents concurrency errors in Swift 6 projects |
| **Component reference** | Gives the AI exact initializer signatures so it generates code that compiles |
| **Common patterns** | Idiomatic examples prevent the AI from inventing plausible-but-wrong usage |
| **Do not** | Anti-patterns that produce non-compiling or poorly-branded results |
