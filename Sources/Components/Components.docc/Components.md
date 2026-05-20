# ``Components``

Themeable, cross-platform SwiftUI views and modifiers built on top of `DesignSystem` tokens.

## Overview

`Components` provides production-ready UI building blocks — buttons, inputs, badges, cards, and layout containers — that automatically adapt to whatever `Theme` is injected through the environment.

### Interactive Showcase

Clone the repository and run the **ComponentShowcase** executable target to interact with every component live:

```bash
open Package.swift   # Opens in Xcode — select the ComponentShowcase scheme and run
```

## Topics

### Buttons

@Image(source: "designButtons.png", alt: "Button component variants")

- ``ThemeButton``
- ``ThemeButtonRole``
- ``ThemeButtonStyle``
- ``CompactActionButton``

### Controls

@Image(source: "designSearchBar.png", alt: "SearchBar component")
@Image(source: "designToggle.png", alt: "Toggle style component")

- ``SearchBar``
- ``ThemeToggleStyle``

### Selection

@Image(source: "designPillChips.png", alt: "PillChip selection components")

- ``MenuPicker``
- ``MenuPickerItem``
- ``PillChip``

### Indicators

@Image(source: "designBadges.png", alt: "Badge indicator variants")

- ``Badge``

### Typography

@Image(source: "designTextStyles.png", alt: "Typography styles")

- ``TextRole``
- ``TypeStyle``

### Surfaces

@Image(source: "designCardSurface.png", alt: "CardSurface component")
@Image(source: "designCapsuleSurface.png", alt: "CapsuleSurface component")
@Image(source: "designInputSurface.png", alt: "InputSurface component")
@Image(source: "designAdaptiveSurface.png", alt: "AdaptiveSurface component")

- ``CardSurface``
- ``CapsuleSurface``
- ``InputSurface``
- ``AdaptiveSurface``
- ``SelectableCardSurface``

### Layout

@Image(source: "designContainers.png", alt: "Container layout components")

- ``Container``
- ``ContainerStyle``
- ``FlowLayout``
- ``SectionHeader``

### Navigation

@Image(source: "designPagedView.png", alt: "TitledPageView paged navigation")

- ``TitledPageView``
- ``TitledPageTitleAlignment``
- ``TitledPageViewContext``
- ``PaginationIndicatorStyle``
- ``PaginationPeekDirection``
- ``PaginationStyle``

### Feedback

@Image(source: "designEmptyState.png", alt: "EmptyStateView component")
@Image(source: "designErrorBanner.png", alt: "ErrorBanner component")
@Image(source: "designErrorSection.png", alt: "ErrorSection component")
@Image(source: "designLoading.png", alt: "Loading view components")

- ``EmptyStateView``
- ``LoadingView``
- ``GhostLoadingBlock``
- ``AsyncContentView``
- ``ErrorBanner``
- ``ErrorSection``
- ``ChatBubble``
- ``ChatBubbleView``
- ``ChatMessageRole``
- ``TypingDotsView``
- ``TypingIndicatorBubbleView``

### Media

- ``CachedAsyncImage``

### Parsing

- ``StructuredMessageParser``
