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
- ``MenuPicker/PresentationStyle``
- ``SelectionListView``
- ``SelectionListContentView``
- ``SelectionNode``
- ``PillChip``
- ``PillMetrics``
- ``ActionPill``

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
- ``FlipCard``
- ``DisclosureCard``
- ``FlipAxis``

### Layout

- ``Container``
- ``ContainerStyle``
- ``FlowLayout``
- ``SectionHeader``

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
- ``ErrorBanner``
- ``ErrorSection``
- ``NoticeCard``
- ``ToastView``
- ``ToastRole``
- ``ToastAction``
- ``ChatBubble``
- ``ChatBubbleView``
- ``ChatMessageRole``
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
