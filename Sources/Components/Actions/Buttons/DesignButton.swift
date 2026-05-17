import DesignSystem
import SwiftUI

/// Reusable button that follows the active design theme.
///
/// ![Buttons in all roles](designButtons)
public struct DesignButton<Label: View>: View {
    private let role: DesignButtonRole
    private let isLoading: Bool
    private let action: () -> Void
    @ViewBuilder private let label: Label

    /// Creates a themed button.
    public init(
        role: DesignButtonRole = .primary,
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
        .buttonStyle(DesignButtonStyle(role: role))
        .disabled(isLoading)
    }
}

public extension DesignButton where Label == Text {
    /// Creates a themed text button.
    init(
        _ title: String,
        role: DesignButtonRole = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(role: role, isLoading: isLoading, action: action) {
            Text(title)
        }
    }
}

#Preview("Design Buttons") {
    DesignPreviewContent { theme in
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            DesignButton("Primary") {}
            DesignButton("Secondary", role: .secondary) {}
            DesignButton("Tertiary", role: .tertiary) {}
            DesignButton("Delete", role: .destructive) {}
            DesignButton("Loading", isLoading: true) {}
        }
        .padding(theme.spacing.twoUnits)
    }
}
