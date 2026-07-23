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

/// The presentation state of one action in an
/// ``AssistantQuickActionChipRow``.
public enum AssistantQuickActionState: Equatable, Sendable {
    /// The action is visible and can be selected when row interaction is enabled.
    case available
    /// The action is visible, highlighted as already used, and disabled.
    case used
    /// The action remains visible but cannot currently be selected.
    case disabled
    /// The action is omitted from the row.
    case hidden
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
                .font(theme.typography.subheadline.weight(.medium))
                .padding(.horizontal, theme.spacing.twoUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .frame(minHeight: theme.motion.minimumHitTarget)
                .background(isSelected ? theme.colors.primary : theme.colors.containerSecondary)
                .foregroundStyle(foregroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
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

/// Which semantic foreground color an ``AssistantQuickActionChipRow`` chip
/// should use, resolved as a pure function so the decision table is
/// unit-testable without rendering a view.
///
/// Halving the whole button's opacity (background + text together) when
/// disabled leaves the title nearly unreadable against its pill background.
/// A used (selected) chip stays fully legible — `onSelectedFill` is already
/// designed to contrast with the primary fill; a not-yet-usable chip
/// switches its text to the dedicated disabled-but-legible label color
/// instead of dimming it.
public enum AssistantQuickActionChipForegroundRole: Equatable, Sendable {
    case onSelectedFill
    case primaryText
    case disabledText

    /// Resolves the chip's foreground role from its selection/enablement.
    public static func resolve(isSelected: Bool, isEnabled: Bool) -> AssistantQuickActionChipForegroundRole {
        if isSelected { return .onSelectedFill }
        return isEnabled ? .primaryText : .disabledText
    }
}

private enum PreviewAction: String, CaseIterable, Identifiable {
    case translate, explain, examples
    var id: String { rawValue }
}

#Preview("Assistant quick action chip row") {
    PreviewContent { theme in
        AssistantQuickActionChipRow<PreviewAction>(
            actions: PreviewAction.allCases,
            isInteractionEnabled: true,
            state: { $0 == .translate ? .used : .available },
            label: { $0.rawValue.capitalized },
            systemImage: { _ in "text.book.closed" },
            onSelect: { _ in }
        )
        .padding(theme.spacing.twoUnits)
    }
}
