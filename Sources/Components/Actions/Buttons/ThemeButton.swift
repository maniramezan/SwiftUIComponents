import DesignSystem
import SwiftUI

/// Reusable button that follows the active design theme.
///
/// ![Buttons in all roles](designButtons)
public struct ThemeButton<Label: View>: View {
    private let role: ThemeButtonRole
    private let isLoading: Bool
    private let action: () -> Void
    @ViewBuilder private let label: Label

    /// Creates a themed button.
    public init(
        role: ThemeButtonRole = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.role = role
        self.isLoading = isLoading
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                label.opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ThemeButtonStyle(role: role))
        .disabled(isLoading)
    }
}

public extension ThemeButton where Label == Text {
    /// Creates a themed text button.
    init(
        _ title: String,
        role: ThemeButtonRole = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(role: role, isLoading: isLoading, action: action) {
            Text(title)
        }
    }
}

#Preview("Design Buttons") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            ThemeButton("Primary") {}
            ThemeButton("Secondary", role: .secondary) {}
            ThemeButton("Tertiary", role: .tertiary) {}
            ThemeButton("Delete", role: .destructive) {}
            ThemeButton("Loading", isLoading: true) {}
        }
        .padding(theme.spacing.twoUnits)
    }
}
