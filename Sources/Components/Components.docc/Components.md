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

Use ``SphereOrbitTilt`` to configure ``OrbitingSphere`` pitch and roll independently.
Each tilt provides a center angle, a maximum deviation, and an optional cycle duration
in seconds. Omitting the duration preserves timing relative to satellite revolutions;
zero deviation holds a fixed orientation. Tilt configuration applies only to the spatial style.

- ``SphereView``
- ``OrbitingSphere``
- ``SphereOrbitStyle``
- ``SphereOrbitTilt``

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

- ``CachedAsyncImage``

### Parsing

- ``StructuredMessageParser``
