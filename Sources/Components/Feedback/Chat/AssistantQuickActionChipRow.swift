import DesignSystem
import SwiftUI

/// A horizontal quick-action chip row for assistant-style features.
///
/// Callers control each action's presentation after an interaction. An action
/// can be marked used, temporarily disabled, hidden, or renewed by returning
/// it to `.available`.
///
/// Generic over any `Identifiable` action model so callers can show a dynamic
/// action set and supply their own label, icon, and state resolvers.
///
/// ```swift
/// AssistantQuickActionChipRow(
///     actions: viewModel.availableActions,
///     state: { viewModel.presentation(for: $0) },
///     label: { $0.displayName },
///     systemImage: { $0.systemImage },
///     onSelect: { viewModel.run($0) }
/// )
/// ```
public struct AssistantQuickActionChipRow<Action: Identifiable>: View {

    private let actions: [Action]
    private let isInteractionEnabled: Bool
    private let state: (Action) -> AssistantQuickActionState
    private let label: (Action) -> String
    private let systemImage: (Action) -> String?
    private let onSelect: (Action) -> Void

    /// Creates a quick-action chip row.
    ///
    /// - Parameters:
    ///   - actions: Actions to display, in presentation order.
    ///   - isInteractionEnabled: Gates every not-yet-used chip — `false`
    ///     while a request is in flight (so a second action can't be tapped
    ///     mid-stream) or while the feature is otherwise unavailable.
    ///   - state: Resolves each action's presentation. `.hidden` actions are
    ///     omitted, `.used` actions are highlighted and disabled, `.disabled`
    ///     actions are visible but disabled, and `.available` actions can be
    ///     selected when interaction is enabled. Renew an action by resolving
    ///     it as `.available` again.
    ///   - label: Resolves a chip's display title.
    ///   - systemImage: Resolves a chip's optional leading SF Symbol.
    ///     Defaults to no icon.
    ///   - onSelect: Called when the caller taps an available, enabled chip.
    public init(
        actions: [Action],
        isInteractionEnabled: Bool,
        state: @escaping (Action) -> AssistantQuickActionState = { _ in .available },
        label: @escaping (Action) -> String,
        systemImage: @escaping (Action) -> String? = { _ in nil },
        onSelect: @escaping (Action) -> Void
    ) {
        self.actions = actions
        self.isInteractionEnabled = isInteractionEnabled
        self.state = state
        self.label = label
        self.systemImage = systemImage
        self.onSelect = onSelect
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.oneAndHalfUnits) {
                ForEach(actions) { action in
                    let actionState = state(action)
                    if actionState != .hidden {
                        AssistantQuickActionChip(
                            title: label(action),
                            systemImage: systemImage(action),
                            state: actionState,
                            isInteractionEnabled: isInteractionEnabled,
                            onTap: { onSelect(action) }
                        )
                    }
                }
            }
        }
    }
}

/// A single chip in an ``AssistantQuickActionChipRow``.
private struct AssistantQuickActionChip: View {
    let title: String
    let systemImage: String?
    let state: AssistantQuickActionState
    let isInteractionEnabled: Bool
    let onTap: () -> Void

    @Environment(\.designTheme) private var theme

    private var isSelected: Bool { state == .used }
    private var isEnabled: Bool { isInteractionEnabled && state == .available }

    var body: some View {
        Button(action: onTap) {
            AssistantQuickActionChipLabel(title: title, systemImage: systemImage)
                .font(theme.typography.subheadlineMedium)
                .designPillMetrics()
                .designCapsuleSurface(isSelected: isSelected)
                .foregroundStyle(foregroundColor)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        // A used chip is conveyed visually by its filled capsule; say so to VoiceOver too.
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct AssistantQuickActionChipLabel: View {
    let title: String
    let systemImage: String?

    var body: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }
}

private extension AssistantQuickActionChip {
    var foregroundColor: Color {
        switch AssistantQuickActionChipForegroundRole.resolve(isSelected: isSelected, isEnabled: isEnabled) {
        case .onSelectedFill: theme.colors.onPrimary
        case .primaryText: theme.colors.textPrimary
        case .disabledText: theme.colors.disabled
        }
    }
}

private enum PreviewAction: String, CaseIterable, Identifiable {
    case summarize, expand, rephrase
    var id: String { rawValue }
}

#Preview("Assistant quick action chip row") {
    PreviewContent { theme in
        AssistantQuickActionChipRow<PreviewAction>(
            actions: PreviewAction.allCases,
            isInteractionEnabled: true,
            state: { $0 == .summarize ? .used : .available },
            label: { $0.rawValue.capitalized },
            systemImage: { _ in "sparkles" },
            onSelect: { _ in }
        )
        .padding(theme.spacing.twoUnits)
    }
}
