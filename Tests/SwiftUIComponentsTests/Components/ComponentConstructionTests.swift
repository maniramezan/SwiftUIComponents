import Components
import DesignSystem
import Foundation
import SwiftUI
import Testing

@Test("Themed components are constructible")
@MainActor
func themedComponentsAreConstructible() {
    _ = ThemeButton("Continue") {}
    _ = Button("Continue") {}
        .buttonStyle(ThemeButtonStyle(role: .secondary))
    _ = Toggle("Enabled", isOn: .constant(true))
        .toggleStyle(ThemeToggleStyle())
    _ = Container {
        Text("Content")
    }
    _ = Badge("Beta")
    _ = PillChip("All", isSelected: true) {}
    _ = SearchBar(text: .constant(""))
    _ = LoadingView("Loading")
    _ = EmptyStateView(title: "No Items", message: "Try again", systemImage: "tray")
    _ = Text("Error")
        .designTextStyle(.error)
        .designCardSurface()
    _ = ErrorBanner("Something failed.")
    _ = ErrorSection(message: "Could not load.")
    _ = ErrorSection(title: "Network Error", message: "Offline.")
    _ = Text("Adaptive").designAdaptiveSurface()
    _ = Text("Adaptive Tinted").designAdaptiveSurface(tint: .blue.opacity(0.2))
    _ = Text("Selectable").designSelectableCardSurface(isSelected: false)
    _ = Text("Selectable On").designSelectableCardSurface(isSelected: true)
    _ = FlipCard {
        Text("Front")
    } back: {
        Text("Back")
    }
    _ = FlipCard(initiallyFaceUp: false, axis: .vertical) {
        Text("Front")
    } back: {
        Text("Back")
    }
    _ = FlipCard(isFaceUp: .constant(true)) {
        Text("Front")
    } back: {
        Text("Back")
    }
    _ = Button("Action") {}.designAdaptiveButtonStyle()
    _ = Button("Prominent") {}.designAdaptiveButtonStyle(prominent: true)
    _ = NavigationStack {
        Text("Content")
            .toolbar {
                DismissToolbarButton {}
                ConfirmToolbarButton(accessibilityLabel: "Save") {}
            }
    }

    _ = FlowLayout(spacing: 8, lineSpacing: 8) {
        Text("A")
        Text("B")
    }
    _ = GhostLoadingBlock(height: 16)
    _ = GhostLoadingBlock(width: 120, height: 48, cornerRadius: 12)
    _ = SectionHeader(title: "Recent")
    _ = SectionHeader(title: "Vocabulary", actionLabel: "See All") {}
    _ = ChatBubbleView(role: .user, content: "Hello")
    _ = ChatBubbleView(role: .assistant, content: "**Hi** there")
    _ = ChatBubbleView(role: .assistant, content: "", isTyping: true)
    _ = ChatBubble(role: .system) { Text("System") }
    _ = TypingDotsView()
    _ = TypingIndicatorBubbleView()
    _ = CompactActionButton(title: "Grammar", icon: "book") {}
    _ = CompactActionButton(title: "Translate", icon: "globe", isDisabled: true) {}

    _ = CachedAsyncImage(url: URL(string: "https://example.com/a.png"), cache: StubCache()) {
        image in
        image
    } placeholder: {
        Color.gray
    }
    _ = AsyncContentView(state: LoadingState<String, StubFailure>.idle) { value in
        Text(value)
    } loadingContent: {
        LoadingView()
    } errorContent: { failure in
        Text(failure.message)
    }

    let pages: [ConstructionPage] = [
        ConstructionPage(id: 0, title: "First"),
        ConstructionPage(id: 1, title: "Second"),
    ]
    let pageSelection: Binding<Int> = .constant(0)
    _ = TitledPageView(pages, selection: pageSelection, title: \ConstructionPage.title) { page in
        Text(page.title)
    }
}

// MARK: - Rendering (exercises ThemeToggleCapsule's isOn branches)

@Test("ThemeToggleStyle renders both the on and off capsule states")
@MainActor
func themeToggleStyleRendersBothStates() {
    renderForCoverage(
        Toggle("Enabled", isOn: .constant(true))
            .toggleStyle(ThemeToggleStyle())
    )
    renderForCoverage(
        Toggle("Disabled", isOn: .constant(false))
            .toggleStyle(ThemeToggleStyle())
    )
}

private struct ConstructionPage: Identifiable {
    let id: Int
    let title: String
}

private struct StubFailure: Error, Equatable, Sendable {
    let message: String
}

private struct StubCache: ImageCacheStore {
    func imageData(for url: URL) async throws -> Data { Data() }
    func removeValue(for url: URL) async throws {}
}
