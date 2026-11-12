import DesignSystem
import SwiftUI

/// A prominent floating action button with a circular or extended capsule label.
///
/// Position the button using the containing layout or an overlay. Supply a SwiftUI
/// `Label` so its title remains available to assistive technologies when only the
/// icon is visible. Caller-supplied content is rendered verbatim.
///
/// ```swift
/// FloatingActionButton(action: { addItem() }) {
///     Label("Add item", systemImage: "plus")
/// }
/// ```
public struct FloatingActionButton<Label: View>: View {
    private let showsTitle: Bool
    private let action: () -> Void
    private let label: Label

    /// Creates a floating action button that respects SwiftUI's disabled environment.
    ///
    /// - Parameters:
    ///   - showsTitle: Whether to display the full label in a capsule. Defaults to
    ///     an icon-only circle whose accessible name still includes the title.
    ///   - action: Invoked when the enabled button is activated.
    ///   - label: Caller-localized content, normally a SwiftUI `Label`.
    public init(
        showsTitle: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.showsTitle = showsTitle
        self.action = action
        self.label = label()
    }

    /// The prominent themed button and its accessible label.
    public var body: some View {
        Button(action: action) {
            FloatingActionButtonLabel(showsTitle: showsTitle, label: label)
                .designCapsuleSurface(isSelected: true)
        }
        .buttonStyle(FloatingActionPressStyle())
    }
}

private struct FloatingActionButtonLabel<Label: View>: View {
    let showsTitle: Bool
    let label: Label
    @Environment(\.designTheme) private var theme
    @ScaledMetric(relativeTo: .title3) private var scale = 1.0

    var body: some View {
        let diameter = max(theme.motion.minimumHitTarget, theme.spacing.sixUnits * scale)
        Group {
            if showsTitle {
                label
                    .labelStyle(.titleAndIcon)
                    .designPillMetrics()
                    .frame(minHeight: diameter)
            } else {
                label
                    .labelStyle(.iconOnly)
                    .frame(width: diameter, height: diameter)
                    .contentShape(Circle())
            }
        }
        .font(theme.typography.title3Semibold)
    }
}

struct FloatingActionPressStyle: ButtonStyle {
    @Environment(\.designTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(
                isEnabled
                    ? (configuration.isPressed ? theme.motion.pressedOpacity : 1)
                    : theme.motion.disabledOpacity
            )
            .animation(theme.motion.animation(reducingMotion: reduceMotion), value: configuration.isPressed)
            .animation(theme.motion.animation(reducingMotion: reduceMotion), value: isEnabled)
    }
}

#Preview("Floating action buttons") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.twoUnits) {
            FloatingActionButton(action: {}) {
                Label("Add item", systemImage: "plus")
            }
            FloatingActionButton(showsTitle: true, action: {}) {
                Label("Add item", systemImage: "plus")
            }
        }
        .padding(theme.spacing.twoUnits)
    }
}
