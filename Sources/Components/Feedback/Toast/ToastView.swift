import DesignSystem
import SwiftUI

/// A transient, role-tinted notification card — the visual content of a toast.
///
/// `ToastView` is the standalone card shown by the
/// `.toast(_:role:systemImage:isPresented:edge:duration:action:)` modifier,
/// but it can also be rendered directly anywhere a self-contained status message
/// is useful. It pairs a role-tinted SF Symbol with a message and an optional
/// trailing ``ToastAction``.
///
/// ```swift
/// ToastView("Saved to your library", role: .success)
/// ToastView("Check your connection", role: .error, systemImage: "wifi.slash")
/// ToastView("Item deleted", role: .info, action: .init("Undo") { restore() })
/// ```
///
/// The ``ToastRole`` determines the accent color and default icon:
/// - `.info` → `theme.colors.primary`, `info.circle.fill`
/// - `.success` → `theme.colors.success`, `checkmark.circle.fill`
/// - `.warning` → `theme.colors.warning`, `exclamationmark.triangle.fill`
/// - `.error` → `theme.colors.error`, `xmark.octagon.fill`
public struct ToastView: View {

    private let message: String
    private let role: ToastRole
    private let systemImage: String?
    private let action: ToastAction?
    @Environment(\.designTheme) private var theme

    /// Creates a toast card.
    ///
    /// - Parameters:
    ///   - message: The text shown to the user. Rendered verbatim, so localize it on your side.
    ///   - role: The semantic role controlling accent color and default icon. Defaults to `.info`.
    ///   - systemImage: An optional SF Symbol name overriding the role's default icon.
    ///   - action: An optional trailing action (e.g. "Undo"). Defaults to `nil`.
    public init(
        _ message: String,
        role: ToastRole = .info,
        systemImage: String? = nil,
        action: ToastAction? = nil
    ) {
        self.message = message
        self.role = role
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.oneUnit) {
                Image(systemName: iconName)
                    .font(theme.typography.callout)
                    .foregroundStyle(accentColor)
                    .accessibilityHidden(true)
                Text(message)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(Strings.Toast.accessibilityLabel(role: role, message: message)))

            if let action {
                Button(action: action.handler) {
                    Text(action.title)
                        .font(theme.typography.button)
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)
                .frame(minWidth: theme.motion.minimumHitTarget, minHeight: theme.motion.minimumHitTarget)
            }
        }
        .padding(.vertical, theme.spacing.oneAndHalfUnits)
        .padding(.horizontal, theme.spacing.twoUnits)
        .background(
            theme.colors.container,
            in: RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
        }
    }
}

// MARK: - Theming

extension ToastView {

    /// SF Symbol shown at the leading edge — the caller's override if provided,
    /// otherwise the role's default icon.
    private var iconName: String {
        if let systemImage { return systemImage }
        switch role {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }

    /// Role-derived accent color for the icon and action button.
    @MainActor fileprivate var accentColor: Color {
        switch role {
        case .info: theme.colors.primary
        case .success: theme.colors.success
        case .warning: theme.colors.warning
        case .error: theme.colors.error
        }
    }
}

#Preview("Toast — roles") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneUnit) {
            ToastView("Saved to your library", role: .success)
            ToastView("New version available", role: .info)
            ToastView("Battery is low", role: .warning)
            ToastView("Upload failed", role: .error, systemImage: "wifi.slash")
            ToastView("Item deleted", role: .info, action: .init("Undo") {})
        }
        .padding(theme.spacing.twoUnits)
    }
}
