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

- ``ThemeButton``
- ``ThemeButtonRole``
- ``ThemeButtonStyle``
- ``CompactActionButton``

### Controls

- ``SearchBar``
- ``ThemeToggleStyle``

### Selection

- ``MenuPicker``
- ``MenuPickerItem``
- ``PillChip``
- ``SegmentedPicker``

### Indicators

- ``Badge``

### Typography

- ``TextRole``
- ``TypeStyle``

### Surfaces

- ``CardSurface``
- ``CapsuleSurface``
- ``InputSurface``
- ``AdaptiveSurface``
- ``SelectableCardSurface``

### Layout

- ``Container``
- ``ContainerStyle``
- ``FlowLayout``
- ``SectionHeader``

### Navigation

- ``TitledPageView``
- ``TitledPageTitleAlignment``
- ``TitledPageViewContext``
- ``PaginationIndicatorStyle``
- ``PaginationPeekDirection``
- ``PaginationStyle``
- ``TitledPageSwipeHintConfig``
- ``SwiftUI/View/designSwipeHint(_:)``

### Feedback

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
