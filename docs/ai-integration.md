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

SwiftUIComponents currently ships four SwiftPM library products:

- `DesignSystem`: design tokens and theming primitives.
- `Components`: reusable SwiftUI views and modifiers. Depends on `DesignSystem`.
- `ComponentShowcase`: demo/reference screens exposed as a library product for previews and exploration. Do not depend on this from production app targets.
- `SwiftUIComponentsDynamic`: one dynamic library containing `DesignSystem` and `Components`.

For application code, import the first two:

    // tokens: spacing, radius, stroke, motion, colors, typography
    import DesignSystem
    // views and modifiers — depends on DesignSystem
    import Components

Platforms: iOS 18+, macOS 15+, Mac Catalyst 18+. Swift language mode: 6 (strict concurrency).

### Package Architecture Decisions

- `DesignSystem` owns reusable token contracts, neutral defaults, and theme environment wiring. App-specific theme implementations belong in the consuming app.
- `Components` owns reusable UI primitives and view modifiers. Shared app UI should live here, not in `ComponentShowcase`.
- `ComponentShowcase` is for demos, previews, and exploration only. Do not import it into shipping app code.
- Apply `.designTheme(...)` once near the root of a feature or app. Components read the active theme from the environment.
- Prefer composing with existing components and modifiers before creating app-local lookalikes.

### Spheres and Orbits

`SphereView(diameter:tint:content:)` draws a shaded sphere with arbitrary upright content.
Its default diameter is `theme.spacing.sixUnits * 2`, and tint defaults to `theme.colors.primary`.

`OrbitingSphere(_:center:satellite:)` accepts an array of uniquely identifiable models and real
SwiftUI center/satellite views. Use your existing models; no package-specific data model is required.
Configure appearance and behavior with modifiers rather than initializer arguments:

    OrbitingSphere(items) {
        SphereView { Image(systemName: "plus") }
    } satellite: { item in
        Button(item.label) { select(item) }
    }
    .sphereOrbitStyle(.ring)
    .sphereOrbitPaused()
    .frame(width: 300, height: 300)

- `.sphereOrbitStyle(_:)` selects `.spatial` for perspective and occlusion, or `.ring` for a flat circle.
- `.sphereOrbitPaused(_ paused: Bool = true)` pauses revolution and tilt while preserving elapsed time.
  Use it for interactive controls. Collection transitions remain enabled.
- `.sphereOrbitConfiguration(_:)` accepts a reusable
  `SphereOrbitConfiguration(style:radius:phase:showsOrbit:)` value for placement and the decorative guide.
- `.sphereOrbitMotion(_:)` accepts a reusable
  `SphereOrbitMotion(isPaused:revolutionDuration:pitch:roll:animatesChanges:)` value.
  Presets `.continuous` and `.paused` retain animated collection changes.

All four modifiers apply to descendant orbits, including through custom container views.
The closest configuration or motion modifier wins. The style and pause modifiers change only
their corresponding field, preserving inherited radius, tilt, timing, and transition settings.
Place those local overrides closer to the orbit than a shared configuration modifier.

The canvas accepts its parent's size proposal. Use ordinary `.frame` modifiers to size it;
without finite constraints, its ideal square side is `theme.spacing.sixUnits * 6`.
When only one proposed dimension is finite, the canvas uses a square. Rectangular frames center the orbit and use
the shorter side to calculate automatic radius: 30% for `.spatial`, 38% for `.ring`.
Sizing the center and satellites to fit is the caller's responsibility; content is not clipped.

Revolution timing defaults to `theme.motion.orbitalRevolutionDuration` (12 seconds per turn).
Reduce Motion, VoiceOver, and inactive scenes pause continuous motion automatically.
Disappearing pauses elapsed time; reappearing resumes accumulated motion while the view's state is retained.
Insertions and removals scale and fade satellites; survivors follow the orbit to their new spacing.
Keep each model's ID stable when updating the array. Transitions work while paused, and use
`theme.motion.animation(reducingMotion:)`. Reduce Motion fades only and updates spacing immediately.
Set `animatesChanges: false` in the motion settings to apply collection updates immediately.

The motion settings' `pitch` and `roll` each accept a `SphereOrbitTilt(center:amplitude:cycleDuration:)`.
Angles use SwiftUI `Angle`; amplitude is the maximum deviation on either side of the center.
Zero amplitude holds a fixed angle. Defaults are `.defaultPitch` (−0.65 ± 0.30 radians) and
`.defaultRoll` (0 ± 0.50 radians). A `nil` cycle duration follows satellite timing: pitch completes
one oscillation in `revolutionDuration / 0.37` seconds, roll in `revolutionDuration / 0.23` seconds.
Set a positive duration in seconds to control each tilt independently of satellite speed.
Both start at their center toward the positive limit, share pause/accessibility behavior, and are
ignored by `.ring`. Nonfinite centers and nonfinite/negative amplitudes log faults and use zero;
nonpositive or nonfinite cycle durations log faults and use `nil`.

    OrbitingSphere(items) {
        SphereView { Text("Center") }
    } satellite: { item in
        SphereView { Text(item.label) }
    }
    .sphereOrbitConfiguration(.init(radius: 90, showsOrbit: false))
    .sphereOrbitMotion(
        .init(
            revolutionDuration: 18,
            pitch: .init(center: .degrees(-35), amplitude: .degrees(20), cycleDuration: 24),
            roll: .init(center: .zero, amplitude: .degrees(30), cycleDuration: 40)
        )
    )
    .frame(width: 320, height: 320)

Migration from the previous initializer is source-breaking:

| Previous initializer argument | Replacement |
| --- | --- |
| `style` | `.sphereOrbitStyle(...)` or configuration `style` |
| `size` | `.frame(width: size, height: size)` |
| `radius`, `phase`, `showsOrbit` | `SphereOrbitConfiguration` through `.sphereOrbitConfiguration(...)` |
| `isAnimating` | `.sphereOrbitPaused(!isAnimating)` |
| `revolutionDuration`, `pitch`, `roll`, `animatesChanges` | `SphereOrbitMotion` through `.sphereOrbitMotion(...)` |

Do not make essential content accessible only through continuously moving or occluded satellites.
Provide stationary controls or use `.sphereOrbitStyle(.ring)` with `.sphereOrbitPaused()`.

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
    // CGFloat
    theme.spacing.twoUnits
    // Color  (@MainActor)
    theme.colors.primary
    // Color (@MainActor)
    theme.colors.segmentUnselectedBackground
    // Color  (@MainActor)
    theme.colors.overlayHeavy
    // Font   (@MainActor)
    theme.typography.body
    // Font (@MainActor)
    theme.typography.captionBold

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

`Typography` requires `controlUIFont` on UIKit platforms and `controlNSFont` on AppKit.
Provide those native fonts in custom conformers; picker triggers dispatch through the protocol.
`DefaultTypography(fontFamily:)` applies its family to both SwiftUI and native control fonts.

All `colors` and `typography` access is @MainActor — use only from View.body or @MainActor functions.

### Component Reference

Buttons:
    ThemeButton("Label", role: .primary, isLoading: false) { }
    // roles: .primary (default) | .secondary | .tertiary | .destructive
    ThemeButton(role: .secondary, action: { }) { Label("Share", systemImage: "square.and.arrow.up") }
    Button("Label") { }.buttonStyle(ThemeButtonStyle(role: .primary))

Compact action:
    CompactActionButton(title: "Action", icon: "star", isDisabled: false) { performAction() }

Section header:
    SectionHeader(title: "Items", actionLabel: "Action", onAction: { performAction() }, titleFont: nil)

Cached images:
    CachedAsyncImage(url: imageURL, cache: imageStore) { image in
        image.resizable().scaledToFit()
    } placeholder: {
        ProgressView()
    }
    CachedAsyncImage(url: imageURL) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
        .imageCache(imageStore)

`ImageCacheStore` is `AnyObject & Sendable`: use an actor or concurrency-safe reference type.
Keep the store's identity stable while its contents remain authoritative. The URL and store identity
jointly identify the request; replacing either cancels loading and clears stale displayed content.
The store owns caching policy. Decoded images are retained only by the view for its current request.
No decoded results are shared globally. Missing URLs or stores display the placeholder; invalid image
bytes are evicted through `removeValue(for:)`.

Search:
    SearchBar(text: $query, placeholder: "Search", isFocused: $isFocused, onSubmit: { })

Labeled text field (title above, helper or error text below; error wins and is read to VoiceOver):
    TextInputField("Email", text: $email, prompt: "name@example.com",
                   // errorMessage: String?
                   helperText: "Used for sign-in only.", errorMessage: emailError)
    TextInputField("Password", text: $password, isSecure: true)
    // Apply .textContentType / .keyboardType / .submitLabel to the TextInputField; they flow through.

Toggle:
    Toggle("Label", isOn: $isOn).toggleStyle(ThemeToggleStyle())

Badge:
    // standard
    Badge("New")
    // primary color fill
    Badge("Pro", isProminent: true)

Avatar (circular; image, else initials of `name`, else a person symbol; VoiceOver label = name):
    // "AL" monogram, .medium
    AvatarView(name: "Ada Lovelace")
    // sizes: .small | .medium | .large
    AvatarView(name: member.name, image: photo, size: .large)

Linear progress (a ProgressViewStyle; nil fractionCompleted sweeps, static under Reduce Motion):
    ProgressView("Uploading", value: sent, total: size)
        .progressViewStyle(ThemeProgressViewStyle())
    ProgressView().progressViewStyle(ThemeProgressViewStyle(tint: theme.colors.success))

List row (leading symbol + title/subtitle + any trailing accessory; min hit-target height):
    ListRow("Storage", subtitle: "12 items", systemImage: "internaldrive") { Text("1.2 GB") }
    ListRow("Notifications", systemImage: "bell") { Toggle("Notifications", isOn: $on).labelsHidden() }
    NavigationLink { Detail() } label: { ListRow("About", systemImage: "info.circle") }

Filter chip:
    PillChip("Label", isSelected: isSelected) {
        // action
    }
    ActionPill(action: openItem) { HStack { Text("Type").bold(); Text("Value") } }

Picker (item must conform to MenuPickerItem: Hashable & Identifiable, var title: String; the package
ships no conformances for Int/String — wrap them in your own type):
    // The package does not conform Int or String to MenuPickerItem. Wrap scalar values:
    struct NumberOption: MenuPickerItem { let id: Int; var title: String { String(id) } }
    MenuPicker(items: allItems, currentValue: $selected)
    MenuPicker(items: allItems, currentValue: $selected, onWidthChange: { newWidth in pickerWidth = newWidth })
    // preferredStyle: .automatic (default) falls back to a wheel sheet past ~30 items; .menu always
    // uses the native dropdown regardless of count — use .menu to keep a picker visually consistent
    // with a sibling MenuPicker whose item count might otherwise cross that threshold.
    MenuPicker(items: allItems, currentValue: $selected, preferredStyle: .menu)
    // Force a wheel sheet even for short lists on iOS/Mac Catalyst; macOS uses a native dropdown.
    MenuPicker(items: allItems, currentValue: $selected, preferredStyle: .wheel)

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
    SegmentedPicker(items: tabs, selection: $tab, sizing: .fillProportionally, density: .compact)
    // sizing: .fit (default) | .fillEqually | .fillProportionally; density: .regular (44pt) | .compact (~32pt)
    // badge; "" = dot
    SegmentedPicker(items: tabs, selection: $tab) { tab in tab.unread > 0 ? "\(tab.unread)" : nil }
    SegmentedPicker(items: tabs, selection: $tab) { tab, _ in
        HStack { Image(systemName: tab.systemImage); Text(tab.title) }
    }

Paging:
    TitledPageView(pages, selection: $selectedID, title: \.title,
                   titleAlignment: .automatic, indicatorStyle: .dots) { page in
        PageContent(page: page)
    }
    .designPaginationStyle(.init(peekDirection: .unidirectional))
    .designSwipeHint(.init(isEnabled: true, delay: 0.6, distance: nil))

    TitledPageView(pages, selection: $selectedID, title: \.title) { context in
        Text(context.currentTitle)
    } footerContent: { context in
        Button("Next") { context.selectPage(context.activeIndex + 1) }
    } content: { page in
        PageContent(page: page)
    }

The keyed initializer adds `id: KeyPath<Element, ID>` before `title:`. You may provide only
`titleContent:` (with `indicatorStyle:`) or only `footerContent:` (with `titleAlignment:`).
The binding uses stable page IDs, never collection offsets. Identity lookup metadata is prepared
from the current collection outside scroll updates. Titles are read from live models during rendering,
including properties on `@Observable` page models. Duplicate IDs log faults and keep the first page.
`peekDirection` changes title presentation only: every mode supports navigation in both directions.
`.none` displays only the active title. Reduce Motion uses opacity transitions when
`reduceMotionUsesCrossfade` is true, including for swipe and accessibility navigation.
Crossfades construct page content on first selection and retain visited pages while their IDs remain
in the collection, preserving local state across navigation and reordering. Inactive pages stay mounted
but are hidden from interaction and accessibility; removing a page releases its local state.
`.designSwipeHint(enabled:)` changes only enablement; inherited delay and distance are preserved.
Put narrow local overrides closer to the pager than complete inherited configurations.

Carousel row (horizontal, browse-only; reveals a sliver of the next item; edge-fade veil):
    // Identifiable convenience
    CarouselRow(apps) { app in FeaturedCard(app) }
    CarouselRow(values, id: \.self, sizing: .peek(visibleCount: 2)) { v in Card(v) }
    CarouselRow(icons, sizing: .fixedWidth(120), snapping: .free) { i in Tile(i) }
    // stacked rows require rowHeight
    CarouselRow(apps, rows: 2, rowHeight: 180) { app in Card(app) }
    // sizing: .peek(visibleCount:peek:) (default, one item + sliver) | .fixedWidth(_) | .fitContent
    // snapping: .viewAligned (default, snaps + keeps peek) | .free (momentum only)
    // rows: defaults to 1; set rowHeight whenever rows > 1

Carousel board (App-Store-style two-directional layout: vertical shelves, each scrolls horizontally):
    CarouselBoard {
        // peeking
        CarouselShelf("Featured", shelfID: "featured", items: apps) { app in FeaturedCard(app) }
        // fixed tiles + action
        CarouselShelf("Top Free", items: apps, actionLabel: "See All",
                      sizing: .fixedWidth(120), onSeeAll: { openAll() }) { app in IconTile(app) }
        CarouselShelf("Continue Watching", items: videos, rows: 2, rowHeight: 180,
                      titleFont: .title3) { video in VideoCard(video) }
        // different item TYPE
        CarouselShelf("Top Stories", items: stories) { story in ArticleCard(story) }
        // fully custom row
        CarouselShelf("Editor's Pick") { EditorsBanner() }
    }
    // Shelves are heterogeneous — each may carry its own item type and item view.
    // Use unique shelfID values when titles can change or repeat; nil defaults to the title.
    // Use CarouselBoardContent (no inner ScrollView) to embed shelves in a scroll you already own.

Container:
    Container(style: .card) { content }
    // styles: .plain | .card (default) | .elevated (shadow) | .outlined

Flip card (two-sided flashcard; tap or VoiceOver "Flip" action toggles it):
    // self-managing — tracks its own flipped state
    FlipCard {
        Text("Bonjour")
    } back: {
        Text("Hello")
    }
    FlipCard(initiallyFaceUp: false, axis: .vertical) { front } back: { back }
    // controlled — drive the face externally
    FlipCard(isFaceUp: $isFaceUp) { front } back: { back }
    // override flip timing
    FlipCard(animation: .spring(duration: 0.5)) { front } back: { back }
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
    // after the last row
    LoadMoreFooter(triggerID: hasMore ? nextCursor : nil, isLoadingMore: isLoading) { loadMore() }

Toast (transient overlay; roles: .info | .success | .warning | .error):
    // standalone card
    ToastView("Saved", role: .success)
    ToastView("Item deleted", role: .info, action: .init("Undo") { restore() })
    // bottom, auto-dismiss 3s
    .toast("Saved", role: .success, isPresented: $showToast)
    .toast("Upload failed", role: .error, isPresented: $showError, edge: .top, duration: .seconds(5))
    .toast("Item deleted", role: .info, isPresented: $showToast,
           // actions persist until dismissed
           action: .init("Undo") { restore() })
    // custom content
    .toast(isPresented: $showToast) { ToastView("Custom", role: .info) }
    // Apply .toast to a full-bleed parent (it anchors an overlay); top/bottom placement is safe-area-aware; honors Reduce Motion; swipe-to-dismiss always on.
    // A11y: announces to VoiceOver on appear and supports the escape (two-finger scrub) gesture to dismiss.
    // Changing duration restarts the timer; adding an action cancels any pending timer.
    // Replacing the message alone keeps the current deadline.

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
    StructuredChatBubbleView(role: .assistant, content: llmResponse, autoPromotingHeadings: ["Summary", "Details"])
    // right-to-left reply inside a left-to-right app: lays the text out RTL, leaves bubble alignment alone
    ChatBubbleView(role: .assistant, content: rtlReply, contentLayoutDirection: .rightToLeft)

Assistant conversation UI (streaming chat feature: quick-action chips + turn log + status banners):
    // Turn model must be Identifiable & Equatable; state drives which bubble variant renders per turn
    AssistantConversationList(
        turns: turns, isInteractionEnabled: !isBusy, idleHint: "Tap an action to get started.",
        // state: .idle | .streaming(String) | .complete(String) | .error(String)
        userLabel: { $0.actionLabel }, responseState: { $0.state },
        retryTitle: "Retry", onRetry: { retry($0.id) },
        // optional, for structured completed responses
        autoPromotingHeadings: ["Summary", "Details"],
        // optional, RTL message text in an LTR app
        contentLayoutDirection: .rightToLeft
    )
    // Actions must be Identifiable. Each action can be available, used, disabled, or hidden.
    AssistantQuickActionChipRow(
        actions: actions, isInteractionEnabled: !isBusy,
        // return .available to renew an action
        state: { actionState(for: $0) },
        label: { $0.displayName }, systemImage: { $0.systemImage }, onSelect: { run($0) }
    )
    // Message field + send; add voiceInput for a mic that becomes stop + level ring while listening.
    // Write the live transcript into `draft`; the composer never clears it, so do that in onSend.
    ChatComposer(text: $draft, prompt: "Message", isEnabled: !isBusy) { send(draft); draft = "" }
    ChatComposer(
        text: $draft,
        voiceInput: ChatComposerVoiceInput(
            // .idle / .listening(level: 0...1) / .processing / .unavailable
            state: voiceState,
            onStart: { startDictation() }, onStop: { stopDictation() }
        )
    ) { send(draft) }
    AssistantContextCard(title: "Example item", highlight: "Label", bodyText: "The sentence this item appeared in.", bodyStyle: .quoted, footnote: "From: Reference source")
    AssistantStatusBanner(message: "The assistant is temporarily unavailable.")
    AssistantUnavailableBanner(reason: "Turn on X in Settings to use this.", settingsAction: .init(title: "Open Settings", action: { openSettings() }))
    AssistantUpgradeNotice(message: "Upgrade to Premium for unlimited assistant help.", upgradeTitle: "Upgrade", onUpgrade: { presentPaywall() })
    AssistantLimitPromptCard(message: "You've reached today's limit.", supportingText: "Upgrade for unlimited help.", primaryActionTitle: "Upgrade", secondaryActionTitle: "Not now", onPrimaryAction: { presentPaywall() }, onSecondaryAction: { dismiss() })
    AssistantDisclaimerFooter(text: "AI responses can be inaccurate. Always double-check important information.")
    TypewriterReveal(text: streamingResponse, charactersPerSecond: 60) { revealed in
        ChatBubbleView(role: .assistant, content: revealed)
    }

Structured messages retain an observable presentation model for the view's lifetime. A lifecycle task
prepares Markdown only when the content, role, typing state, promoted labels, or section threshold changes.
Until preparation finishes, the current source text is shown without stale content from an earlier request.
Unrelated parent updates reuse the prepared sections or attributed fallback. Parsing preserves the
original Markdown fallback when there is a nonempty preamble or an unclosed code fence.
Bare labels are promoted only at line starts, followed by whitespace and an uppercase or non-ASCII
letter. Labels embedded in prose stay untouched. Headings inside code fences stay body text.
`StructuredMessageParser.Section.id` is a deterministic `String` built from heading and duplicate
occurrence; manual construction uses `Section(id:title:body:)` with caller-owned identity.
Repeated headings remain distinct. Keep the source message when `sections(from:)` returns `nil`.
Typewriter deadlines survive streaming extensions; disappearing pauses the schedule. Reduce Motion
and VoiceOver display the complete current target immediately.

Modifiers:
    // rounded card with border
    .designCardSurface()
    // card without border
    .designCardSurface(showStroke: false)
    // pill surface
    .designCapsuleSurface()
    // selected state
    .designCapsuleSurface(isSelected: true)
    // text field background
    .designInputSurface()
    // full-width rounded notice/banner/error card
    .designNoticeCard(background: theme.colors.error)
    // capsule-pill padding + min height + content shape
    .designPillMetrics()
    // font + color from theme
    .designTextStyle(.headline)
    // text roles: .title | .headline | .body | .secondary | .caption | .error
    // full type scale (font only, no color): DesignText("Label", slot: .title3Semibold)
    // slot: one case per Typography member (base slots + weight ladder); DesignText(verbatim:slot:) for un-localized
    // card surface with a selected state
    .designSelectableCardSurface(isSelected: true)
    // glass on iOS/macOS 26+, .ultraThinMaterial below
    .designAdaptiveSurface()
    .designAdaptiveSurface(interactive: true, shape: .circle)
    .designAdaptiveSurface(shape: .capsule, fallbackBorderColor: .white)
    // Reduce Transparency uses regular material; compatibility mode uses a material fallback.
    // cornerRadius applies to .roundedRectangle; fallbackBorderWidth defaults to theme.stroke.thin.
    // .glass button on 26+, .bordered below; honors UIDesignRequiresCompatibility
    .designAdaptiveButtonStyle(prominent: true)
    // sweep highlight across skeleton content (see "Feedback")
    .designGhostShimmer()

Motion tokens:
    // reduced vs standard animation
    theme.motion.animation(reducingMotion: reduceMotion)
    // commit a gesture-driven page change
    reduceMotion ? nil : theme.motion.pagingSpring.animation
    // return after a cancelled gesture
    reduceMotion ? nil : theme.motion.snapBackSpring.animation

`MotionSpring` is a `Hashable`, `Sendable` value with mutable `response`, `dampingFraction`,
and `blendDuration` parameters. Its `animation` property creates an interactive spring;
it does not automatically honor Reduce Motion. Both motion spring requirements have defaults
so existing `Motion` conformers continue to compile. Override them with:

    let motion = DefaultMotion(
        pagingSpring: MotionSpring(response: 0.32, dampingFraction: 0.88, blendDuration: 0.12),
        snapBackSpring: .snapBack
    )

### Common Patterns

Filter chip group (wrapping; use a horizontal ScrollView + HStack instead for a single scrolling line):
    FlowLayout(spacing: theme.spacing.oneUnit, lineSpacing: theme.spacing.oneUnit) {
        ForEach(filters) { f in
            PillChip(f.label, isSelected: selected == f) { selected = f }
        }
    }

Themed text field:
    // labeled, with validation text
    TextInputField("Email", text: $email, errorMessage: emailError)
    // bare field on the input surface
    TextField("Email", text: $email)
        .padding(theme.spacing.oneAndHalfUnits)
        .designInputSurface()

Async screen with pagination:
    AsyncContentView(state: viewModel.state) { items in
        LazyVStack {
            ForEach(items) { ListRow($0.title, subtitle: $0.detail) }
            LoadMoreFooter(triggerID: viewModel.nextCursor, isLoadingMore: viewModel.isLoadingMore) {
                viewModel.loadMore()
            }
        }
    } loadingContent: { LoadingView() } errorContent: { ErrorBanner($0.localizedDescription) }

Loading / empty / content:
    if isLoading { LoadingView("Fetching…") }
    else if items.isEmpty { EmptyStateView(title: "Nothing here yet", systemImage: "tray") {
        ThemeButton("Refresh") { load() }
    }}
    else {
        List(items) {
            // row
        }
    }

Use the showcase for reference, not reuse:
    // Good: copy interaction patterns from ComponentShowcase into app code using Components APIs.
    // Good: host `ShowcaseRootView()` in a scratch/debug app target to browse every component live.
    // Avoid: importing ComponentShowcase into the shipping app target.

### Accessibility & Localization

- Components include VoiceOver support out of the box (labels, traits, hidden decorations, Reduce Motion, adjustable/scroll actions on paged + segmented controls).
- The package localizes only its own chrome (dismiss button, loading/typing announcements, error prefix, paginator + clear-search labels, chat-composer placeholder, field name + send/voice button labels) via a String Catalog in `Bundle.module`; supported locales are translated and validated in CI.
- Content you pass in is rendered verbatim and is your app's responsibility to localize: `ThemeButton` titles, `SearchBar` and `ChatComposer` placeholders, `SelectionNode` titles, `TextInputField` titles and messages, `ListRow` text, `AvatarView` names, `ConfirmToolbarButton` accessibility label. Pass already-localized values (e.g. `String(localized:)`).

### Do Not

- Don't import only `DesignSystem` when you need views — `Components` is a separate SPM product.
- Don't import `ComponentShowcase` into production targets — it is a demo/reference layer.
- Don't access `theme.colors` or `theme.typography` outside @MainActor — they are @MainActor-isolated.
- Don't skip `.designTheme()` — a default exists but won't match your brand.
- Don't conform `MenuPickerItem` items with only `Identifiable` — `Hashable` is also required.
- Don't hand-roll a title-above-field form input or a settings row — use `TextInputField` and `ListRow`.
- Don't put reusable shipping components in the showcase target — promote them into `Components` first.
- Don't pass a String literal to ThemeButton's @ViewBuilder init — use the String convenience init.
- Don't pass unlocalized literals as component content (titles, placeholders, accessibility labels) — these are rendered verbatim, so localize them on your side.
- Don't nest `CarouselRow` inside another horizontal `ScrollView` — it measures its own finite width to size items, which an unbounded horizontal proposal can't provide. It works in any finite-width slot, including a flexible `HStack` slot next to fixed siblings.
- Don't nest `CarouselBoard` inside another vertical `ScrollView` — it owns its own scroll. Use `CarouselBoardContent` to embed shelves in a scroll you already manage.
- Don't wrap chat bubbles in `.environment(\.layoutDirection, .rightToLeft)` to render a right-to-left reply — that mirrors the row and flips which side of the screen each role sits on. Pass `contentLayoutDirection: .rightToLeft` per bubble instead; role alignment is leading/trailing, so a genuinely right-to-left *localization* still mirrors correctly on its own.
- Don't reimplement a streaming chat feature (turn log, quick-action chips, status banners, message field) from scratch — compose `AssistantConversationList`, `AssistantQuickActionChipRow`, `AssistantContextCard`, `AssistantUnavailableBanner`, `AssistantUpgradeNotice`, and `ChatComposer` instead; they're generic over your own turn/action model.
- Don't let users type while `ChatComposer` is listening — it pauses editing for you; keep writing the live transcript into the text binding and let them edit after recognition stops.
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

### Paging swipe hint persistence

`TitledPageView` automatically plays its swipe hint once per host app installation,
shared across instances and app launches. It records playback when the animation begins;
disabled hints, Reduce Motion, and single-page collections do not consume it.
