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
- `ComponentShowcase`: demo/reference screens exposed as a library product for previews and exploration. Do not depend on this from production app targets.

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

### Driving AsyncContentView From Your Own State

`AsyncContentView` accepts any `AsyncLoadable`, not only `LoadingState`. If your app
already owns a state enum with its own error type, conform it once instead of converting at
every call site:

    extension MyState: AsyncLoadable {
        var loadingState: LoadingState<Value, MyError> {
            switch self {
            case .idle: .idle
            case .loading: .loading
            case .loaded(let value): .loaded(value)
            case .failed(let error): .failed(error)
            }
        }
    }

    AsyncContentView(state: viewModel.state) { value in ... }
        loadingContent: { LoadingView() }
        errorContent: { error in ... }

### Choosing a Product

Link `DesignSystem` and `Components` for an app whose own modules are static, which is the
common case.

Link `SwiftUIComponentsDynamic` instead — one dynamic image vending both targets — when
your own modules are dynamic frameworks. Static products get copied into each of those
frameworks, and the duplicate `Bundle.module` lookup that follows kills hostless test
bundles (the xctest agent is `Bundle.main`, so the resource bundle is not found). Imports
are unchanged either way:

    .package(url: "https://github.com/maniramezan/swiftuicomponents", from: "0.10.0")
    // then link the product "SwiftUIComponentsDynamic"

    import DesignSystem
    import Components

### Reading Tokens in Custom Views

    @Environment(\.designTheme) var theme
    theme.spacing.twoUnits    // CGFloat
    theme.colors.primary      // Color  (@MainActor)
    theme.colors.segmentUnselectedBackground // Color (@MainActor)
    theme.colors.overlayHeavy // Color  (@MainActor)
    theme.typography.body     // Font   (@MainActor)
    theme.typography.captionBold // Font (@MainActor)

`ColorTheme` also exposes role tokens beyond the core palette — `interactiveSubtle` (a
faint wash of `primary` for chip fills and selected rows), the overlay scrims
`overlaySubtle` / `overlayMedium` / `overlayHeavy` with the fixed `onOverlay` foreground,
the edge-gradient stops `overlayShadowStart` / `overlayShadowEnd` / `overlayBottomTint`,
and `shimmerHighlight`. Each has a protocol-extension default derived from the conformer's
own `primary` or `shadow`, so a custom `ColorTheme` inherits a consistent set and overrides
only what it needs.

Skeleton shimmer (apply once at the root of a skeleton layout, not per block; static under
Reduce Motion, and `\.isGhostShimmerDisabled` forces the static form for snapshot tests):

    VStack { GhostLoadingBlock(height: 16); GhostLoadingBlock(height: 88) }
        .designGhostShimmer()

`Typography` also exposes a weight ladder over its base slots — `largeTitleBold`,
`title2Bold`, `title2Semibold`, `title3Bold`, `title3Semibold`, `headlineSemibold`,
`bodySemibold`, `bodyMedium`, `subheadlineMedium`, `subheadlineSemibold`, `footnoteSemibold`,
`captionSemibold`, `captionBold`, `caption2Bold`. Each has a protocol-extension default
derived from the conformer's own slot, so a custom `Typography` inherits the whole ladder
(custom font family included) and overrides only what its scale defines differently. Reach
for these instead of re-weighting a slot inline at the call site.

`TypographySlot` names any one of those members (base slot or weight variant) as a
type-safe value, and `DesignText("…", slot: .headlineSemibold)` renders a string in that
slot's font — the call-site-safe alternative to passing a raw `Font`. `DesignText` applies
font only; compose `.foregroundStyle(…)` yourself. Use `DesignText(verbatim:slot:)` for
strings that must not be localized. `TypographySlot.font(_:)` resolves the `Font` directly
when a view needs the value.

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
    ActionPill(action: openItem) { HStack { Text("Type").bold(); Text("Value") } }

Picker (item must conform to MenuPickerItem: Hashable & Identifiable, var title: String):
    MenuPicker(items: allItems, currentValue: $selected)
    MenuPicker(items: allItems, currentValue: $selected, onWidthChange: { newWidth in pickerWidth = newWidth })
    // preferredStyle: .automatic (default) falls back to a wheel sheet past ~30 items; .menu always
    // uses the native dropdown regardless of count — use .menu to keep a picker visually consistent
    // with a sibling MenuPicker whose item count might otherwise cross that threshold.
    MenuPicker(items: allItems, currentValue: $selected, preferredStyle: .menu)

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

Carousel row (horizontal, browse-only; reveals a sliver of the next item; edge-fade veil):
    CarouselRow(apps) { app in FeaturedCard(app) }                     // Identifiable convenience
    CarouselRow(values, id: \.self, sizing: .peek(visibleCount: 2)) { v in Card(v) }
    CarouselRow(icons, sizing: .fixedWidth(120), snapping: .free) { i in Tile(i) }
    CarouselRow(apps, rows: 2, rowHeight: 180) { app in Card(app) }    // stacked rows require rowHeight
    // sizing: .peek(visibleCount:peek:) (default, one item + sliver) | .fixedWidth(_) | .fitContent
    // snapping: .viewAligned (default, snaps + keeps peek) | .free (momentum only)
    // rows: defaults to 1; set rowHeight whenever rows > 1

Carousel board (App-Store-style two-directional layout: vertical shelves, each scrolls horizontally):
    CarouselBoard {
        CarouselShelf("Featured", items: apps) { app in FeaturedCard(app) }          // peeking
        CarouselShelf("Top Free", items: apps, actionLabel: "See All",               // fixed tiles + action
                      sizing: .fixedWidth(120), onSeeAll: { openAll() }) { app in IconTile(app) }
        CarouselShelf("Continue Watching", items: videos, rows: 2, rowHeight: 180,
                      titleFont: .title3) { video in VideoCard(video) }
        CarouselShelf("Top Stories", items: stories) { story in ArticleCard(story) }  // different item TYPE
        CarouselShelf("Editor's Pick") { EditorsBanner() }                           // fully custom row
    }
    // Shelves are heterogeneous — each may carry its own item type and item view.
    // Use CarouselBoardContent (no inner ScrollView) to embed shelves in a scroll you already own.

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
    FlipCard(animation: .spring(duration: 0.5)) { front } back: { back }  // override flip timing
    // axis: .horizontal (default, sweeps left/right) | .vertical (sweeps top/bottom)
    // animation: defaults to theme.motion.standardAnimation when omitted
    // Each face is wrapped in a card surface; Reduce Motion replaces the 3D flip with a cross-fade.

Disclosure card (summary remains visible; detail expands inline):
    DisclosureCard(isExpanded: $isExpanded) { summary } detail: { detail }

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
    // Apply .toast to a full-bleed parent (it anchors an overlay); top/bottom placement is safe-area-aware; honors Reduce Motion; swipe-to-dismiss always on.
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
    // structured-or-plain assistant bubble: renders `## ` sections when >= 2 are parsed, else falls back to plain markdown
    StructuredChatBubbleView(role: .assistant, content: llmResponse, autoPromotingHeadings: ["Main Idea", "Examples"])

Assistant conversation UI (streaming chat feature: quick-action chips + turn log + status banners):
    // Turn model must be Identifiable & Equatable; state drives which bubble variant renders per turn
    AssistantConversationList(
        turns: turns, isInteractionEnabled: !isBusy, idleHint: "Tap an action to get started.",
        userLabel: { $0.actionLabel }, responseState: { $0.state },   // state: .idle | .streaming(String) | .complete(String) | .error(String)
        retryTitle: "Retry", onRetry: { retry($0.id) },
        autoPromotingHeadings: ["Main Idea", "Examples"]               // optional, for structured completed responses
    )
    // Actions must be Identifiable. Each action can be available, used, disabled, or hidden.
    AssistantQuickActionChipRow(
        actions: actions, isInteractionEnabled: !isBusy,
        state: { actionState(for: $0) }, // return .available to renew an action
        label: { $0.displayName }, systemImage: { $0.systemImage }, onSelect: { run($0) }
    )
    AssistantContextCard(title: "hello", highlight: "Hola", bodyText: "Hello, how are you?", bodyStyle: .quoted, footnote: "From: lesson 3")
    AssistantStatusBanner(message: "The assistant is temporarily unavailable.")
    AssistantUnavailableBanner(reason: "Turn on X in Settings to use this.", settingsAction: .init(title: "Open Settings", action: { openSettings() }))
    AssistantUpgradeNotice(message: "Upgrade for full support.", upgradeTitle: "Upgrade", onUpgrade: { presentPaywall() })
    AssistantLimitPromptCard(message: "You've reached today's limit.", supportingText: "Upgrade for unlimited help.", primaryActionTitle: "Upgrade", secondaryActionTitle: "Not now", onPrimaryAction: { presentPaywall() }, onSecondaryAction: { dismiss() })
    AssistantDisclaimerFooter(text: "AI responses can be inaccurate. Always double-check important information.")
    TypewriterReveal(text: streamingResponse, charactersPerSecond: 60) { revealed in
        ChatBubbleView(role: .assistant, content: revealed)
    }

Modifiers:
    .designCardSurface()                    // rounded card with border
    .designCardSurface(showStroke: false)   // card without border
    .designCapsuleSurface()                 // pill surface
    .designCapsuleSurface(isSelected: true) // selected state
    .designInputSurface()                   // text field background
    .designNoticeCard(background: theme.colors.error)  // full-width rounded notice/banner/error card
    .designPillMetrics()                    // capsule-pill padding + min height + content shape
    .designTextStyle(.headline)             // font + color from theme
    // text roles: .title | .headline | .body | .secondary | .caption | .error
    // full type scale (font only, no color): DesignText("Label", slot: .title3Semibold)
    // slot: one case per Typography member (base slots + weight ladder); DesignText(verbatim:slot:) for un-localized
    .designSelectableCardSurface(isSelected: true)  // card surface with a selected state
    .designAdaptiveSurface()               // glass on iOS/macOS 26+, .ultraThinMaterial below
    .designAdaptiveButtonStyle(prominent: true)     // .glass button on 26+, .bordered below; honors UIDesignRequiresCompatibility
    .designGhostShimmer()                  // sweep highlight across skeleton content (see "Feedback")

Motion tokens:
    theme.motion.animation(reducingMotion: reduceMotion)  // reduced vs standard animation

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
- The package localizes only its own chrome (dismiss button, loading/typing announcements, error prefix, paginator + clear-search labels) via a String Catalog in `Bundle.module`; supported locales are translated and validated in CI.
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
- Don't nest `CarouselRow` inside another horizontal `ScrollView` — it measures its own finite width to size items, which an unbounded horizontal proposal can't provide. It works in any finite-width slot, including a flexible `HStack` slot next to fixed siblings.
- Don't nest `CarouselBoard` inside another vertical `ScrollView` — it owns its own scroll. Use `CarouselBoardContent` to embed shelves in a scroll you already manage.
- Don't reimplement a streaming chat feature (turn log, quick-action chips, status banners) from scratch — compose `AssistantConversationList`, `AssistantQuickActionChipRow`, `AssistantContextCard`, `AssistantUnavailableBanner`, and `AssistantUpgradeNotice` instead; they're generic over your own turn/action model.
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
