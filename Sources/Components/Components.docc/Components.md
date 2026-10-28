# ``Components``

Themeable, cross-platform SwiftUI views and modifiers built on top of `DesignSystem` tokens.

## Overview

`Components` provides production-ready UI building blocks — buttons, inputs, list rows, avatars, progress, cards, layout containers, paging, carousels, feedback states, and chat UI — that automatically adapt to whatever `Theme` is injected through the environment.

### Interactive Showcase

Clone the repository and open the package in Xcode to interact with every component live. `ComponentShowcase` is a library target: preview `ShowcaseRootView` (or any `*DetailView`) in the canvas, or host `ShowcaseRootView()` from a scratch app target.

```bash
open Package.swift   # Opens in Xcode
```

## Topics

### Essentials

- <doc:Modifiers>

### Buttons

- ``ThemeButton``
- ``ThemeButtonRole``
- ``ThemeButtonStyle``
- ``CompactActionButton``

### Controls

- ``SearchBar``
- ``TextInputField``
- ``ThemeToggleStyle``

### Selection

- ``MenuPicker``
- ``MenuPickerItem``
- ``MenuPicker/PresentationStyle``
- ``MenuPicker/PresentationStyle/wheel``
- ``SelectionListView``
- ``SelectionListContentView``
- ``SelectionNode``
- ``PillChip``
- ``PillMetrics``
- ``ActionPill``

### Indicators

- ``Badge``
- ``AvatarView``
- ``ThemeProgressViewStyle``

### Typography

- ``TextRole``
- ``TypeStyle``
- ``TypographySlot``
- ``DesignText``

### Surfaces

``OrbitingSphere`` takes only identifiable models and center/satellite content builders.
Use `sphereOrbitStyle(_:)` for projection, `sphereOrbitPaused(_:)` to pause continuous motion,
and SwiftUI's `frame` modifiers for canvas size. Reuse ``SphereOrbitConfiguration`` through
`sphereOrbitConfiguration(_:)` for placement and guide settings, and ``SphereOrbitMotion``
through `sphereOrbitMotion(_:)` for revolution, tilt, and collection transitions.
Modifiers apply to descendant orbits; the closest settings win. Style and pause overrides
preserve other inherited configuration. See <doc:Modifiers> for modifier details.

Use ``SphereOrbitTilt`` to configure ``SphereOrbitMotion`` pitch and roll independently.
Each tilt provides a center angle, a maximum deviation, and an optional cycle duration
in seconds. Omitting the duration preserves timing relative to satellite revolutions;
zero deviation holds a fixed orientation. Tilt configuration applies only to the spatial style.

``OrbitingSphere`` animates inserted and removed satellites with scaling and fading, while existing
items follow the orbit to their new spacing. Stable item identities preserve content and rotation.
These transitions work while continuous motion is paused; set the motion's `animatesChanges` to `false` to disable
them. Reduce Motion uses fades and immediate spacing updates.
Disappearing pauses elapsed time; reappearing resumes accumulated motion while the view's state is retained.

- ``SphereView``
- ``OrbitingSphere``
- ``SphereOrbitStyle``
- ``SphereOrbitTilt``
- ``SphereOrbitConfiguration``
- ``SphereOrbitMotion``

- ``CardSurface``
- ``CapsuleSurface``
- ``InputSurface``
- ``AdaptiveSurface``
- ``AdaptiveSurfaceShape``
- ``SelectableCardSurface``
- ``FlipCard``
- ``DisclosureCard``
- ``FlipAxis``

### Layout

- ``Container``
- ``ContainerStyle``
- ``FlowLayout``
- ``SectionHeader``
- ``ListRow``

### Navigation

- ``DismissToolbarButton``
- ``ConfirmToolbarButton``

### Pagination

Title peeking controls appearance only; every mode retains the full page collection and permits
navigation in either direction. `.none` shows only the selected title. With Reduce Motion enabled,
`PaginationStyle.reduceMotionUsesCrossfade` selects opacity transitions for pages and titles.
Stable model IDs connect page content and selection across updates. Titles are read from live models
so Observation can track title changes even when the pager is constructed once. Crossfades create
page content on first selection and keep visited pages mounted while their IDs remain in the collection,
preserving page-local state. Inactive pages are hidden from interaction and accessibility.


- ``TitledPageView``
- ``TitledPageTitleAlignment``
- ``TitledPageViewContext``
- ``PaginationIndicatorStyle``
- ``PaginationPeekDirection``
- ``PaginationStyle``
- ``TitledPageSwipeHintConfig``
- ``SegmentedPicker``
- ``SegmentSizing``
- ``SegmentDensity``

### Collections

- ``CarouselRow``
- ``CarouselItemSizing``
- ``CarouselSnapping``
- ``CarouselBoard``
- ``CarouselBoardContent``
- ``CarouselShelf``
- ``CarouselShelfConvertible``
- ``CarouselShelfBuilder``

### Feedback

``StructuredChatBubbleView`` retains an observable presentation model that prepares sections and
attributed fallback text only when its message or parsing policy changes. Lifecycle-bound preparation
keeps view initialization cheap; pending preparation displays the current source text.

- ``EmptyStateView``
- ``LoadingView``
- ``GhostLoadingBlock``
- ``AsyncContentView``
- ``LoadMoreFooter``
- ``ErrorBanner``
- ``ErrorSection``
- ``NoticeCard``
- ``ToastView``
- ``ToastRole``
- ``ToastAction``
- ``ChatBubble``
- ``ChatBubbleView``
- ``ChatMessageRole``
- ``ChatComposer``
- ``ChatComposerVoiceInput``
- ``ChatComposerVoiceState``
- ``TypingDotsView``
- ``TypingIndicatorBubbleView``
- ``StructuredChatBubbleView``
- ``AssistantConversationState``
- ``AssistantConversationList``
- ``AssistantQuickActionChipRow``
- ``AssistantQuickActionState``
- ``AssistantQuickActionChipForegroundRole``
- ``AssistantContextCard``
- ``AssistantDisclaimerFooter``
- ``AssistantStatusBanner``
- ``AssistantUnavailableBanner``
- ``AssistantUpgradeNotice``
- ``AssistantLimitPromptCard``
- ``TypewriterReveal``

### Media

``CachedAsyncImage`` identifies requests by URL and the reference identity of the injected
`DesignSystem.ImageCacheStore`. The store owns caching policy; the view retains only its current
decoded result. Changing the URL or store cancels the previous request and replaces stale content
with the placeholder. Cache stores must be actors or concurrency-safe reference types.


- ``CachedAsyncImage``

### Parsing

``StructuredMessageParser`` retains heading identity across repeated parses, including duplicate
headings. It returns `nil` instead of discarding a preamble or accepting an unclosed fence. Code
fences and indented code do not produce sections; bare-label promotion applies only at line starts.
`Section(id:title:body:)` accepts explicit `String` identity for manually constructed sections.


- ``StructuredMessageParser``
