import DesignSystem
import SwiftUI

/// A themed row for lists and settings-style screens: an optional leading SF Symbol,
/// a title with an optional subtitle, and an optional caller-supplied trailing accessory.
///
/// The accessory is any view — a value, a ``Badge``, a `Toggle`, or a disclosure
/// chevron — and is styled with the theme's secondary text treatment unless it sets
/// its own. The row reserves the theme's minimum hit-target height, so it can be
/// wrapped in a `Button` or `NavigationLink` without extra padding.
///
/// ```swift
/// List {
///     ListRow("Storage", subtitle: "12 items", systemImage: "internaldrive") {
///         Text("1.2 GB")
///     }
///     ListRow("Notifications", systemImage: "bell") {
///         Toggle("Notifications", isOn: $isOn).labelsHidden()
///     }
///     NavigationLink { DetailView() } label: {
///         ListRow("About", systemImage: "info.circle")
///     }
/// }
/// ```
///
/// VoiceOver reads the title and subtitle as one element; the accessory stays its own
/// element so an interactive control keeps its own label and actions.
public struct ListRow<Accessory: View>: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let iconTint: Color?
    private let accessory: Accessory
    @Environment(\.designTheme) private var theme

    /// Creates a row with a trailing accessory.
    ///
    /// - Parameters:
    ///   - title: The primary text. Rendered verbatim, so localize it on your side.
    ///   - subtitle: Optional secondary text shown beneath the title. Hidden when `nil` or empty.
    ///   - systemImage: Optional SF Symbol shown at the leading edge. Decorative, so it is
    ///     hidden from VoiceOver.
    ///   - iconTint: Color for the leading symbol. When `nil` (the default), the theme's
    ///     `colors.primary` is used.
    ///   - accessory: Trailing content such as a value, badge, or control.
    public init(
        _ title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        iconTint: Color? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.iconTint = iconTint
        self.accessory = accessory()
    }

    /// The themed row.
    public var body: some View {
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            if let systemImage {
                ListRowIcon(systemImage: systemImage, tint: iconTint ?? theme.colors.primary)
            }
            ListRowText(title: title, subtitle: subtitle)
            Spacer(minLength: theme.spacing.oneUnit)
            accessory
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(minHeight: theme.motion.minimumHitTarget)
        .contentShape(Rectangle())
    }
}

public extension ListRow where Accessory == EmptyView {
    /// Creates a row without a trailing accessory.
    ///
    /// - Parameters:
    ///   - title: The primary text. Rendered verbatim, so localize it on your side.
    ///   - subtitle: Optional secondary text shown beneath the title. Hidden when `nil` or empty.
    ///   - systemImage: Optional decorative SF Symbol shown at the leading edge.
    ///   - iconTint: Color for the leading symbol. When `nil` (the default), the theme's
    ///     `colors.primary` is used.
    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil, iconTint: Color? = nil) {
        self.init(title, subtitle: subtitle, systemImage: systemImage, iconTint: iconTint) {
            EmptyView()
        }
    }
}

// MARK: - Subviews

/// The fixed-width leading symbol of a ``ListRow``, so titles align down a list
/// whether or not neighbouring symbols differ in width.
private struct ListRowIcon: View {
    let systemImage: String
    let tint: Color

    @Environment(\.designTheme) private var theme

    var body: some View {
        Image(systemName: systemImage)
            .font(theme.typography.body)
            .foregroundStyle(tint)
            .frame(width: theme.spacing.threeUnits)
            .accessibilityHidden(true)
    }
}

/// The title and optional subtitle of a ``ListRow``, combined into one
/// accessibility element.
private struct ListRowText: View {
    let title: String
    let subtitle: String?

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            Text(title)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(theme.typography.footnote)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("List Row") {
    @Previewable @State var isOn = true

    PreviewContent { theme in
        VStack(spacing: 0) {
            ListRow("Storage", subtitle: "12 items", systemImage: "internaldrive") {
                Text("1.2 GB")
            }
            Divider()
            ListRow("Notifications", systemImage: "bell") {
                Toggle("Notifications", isOn: $isOn).labelsHidden()
            }
            Divider()
            ListRow("About", systemImage: "info.circle") {
                Image(systemName: "chevron.forward")
            }
            Divider()
            ListRow("Plain row")
        }
        .padding(theme.spacing.twoUnits)
    }
}
