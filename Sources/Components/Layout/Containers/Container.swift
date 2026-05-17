import DesignSystem
import SwiftUI

/// Generic themed container for composing shared component layouts.
///
/// ![Card, elevated, and outlined containers](designContainers)
public struct Container<Content: View>: View {
    private let style: ContainerStyle
    @ViewBuilder private let content: Content
    @Environment(\.designTheme) private var theme

    /// Creates a themed container.
    public init(style: ContainerStyle = .card, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    public var body: some View {
        content
            .padding(theme.spacing.twoUnits)
            .background(background, in: RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous)
                    .strokeBorder(border, lineWidth: borderWidth)
            }
            .shadow(color: shadowColor, radius: style == .elevated ? 12 : 0, y: style == .elevated ? 4 : 0)
    }

    @MainActor private var background: Color {
        switch style {
        case .plain, .outlined:
            Color.clear
        case .card, .elevated:
            theme.colors.container
        }
    }

    @MainActor private var border: Color {
        switch style {
        case .outlined:
            theme.colors.border
        case .card, .elevated:
            theme.colors.border
        case .plain:
            Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .plain:
            0
        case .card, .elevated:
            theme.stroke.hairline
        case .outlined:
            theme.stroke.thin
        }
    }

    private var shadowColor: Color {
        .black.opacity(0.08)
    }
}

#Preview("Design Containers") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            Container(style: .card) {
                Text("Card container")
            }
            Container(style: .elevated) {
                Text("Elevated container")
            }
            Container(style: .outlined) {
                Text("Outlined container")
            }
        }
        .padding(theme.spacing.twoUnits)
    }
}
