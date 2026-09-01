import DesignSystem
import SwiftUI

/// Applies the standard geometry for a capsule "pill": vertical `oneUnit`
/// padding, a `minimumHitTarget` height, and a capsule content shape so taps
/// register across the whole pill.
///
/// ```swift
/// Text("Tag")
///     .designPillMetrics()
///     .designCapsuleSurface(isSelected: true)
/// ```
public struct PillMetrics: ViewModifier {
    private let horizontalPadding: CGFloat?
    @Environment(\.designTheme) private var theme

    /// Creates the pill-metrics modifier.
    /// - Parameter horizontalPadding: Horizontal padding override. Defaults to
    ///   `theme.spacing.twoUnits`.
    public init(horizontalPadding: CGFloat? = nil) {
        self.horizontalPadding = horizontalPadding
    }

    /// Applies the pill padding, minimum height, and capsule content shape.
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding ?? theme.spacing.twoUnits)
            .padding(.vertical, theme.spacing.oneUnit)
            .frame(minHeight: theme.motion.minimumHitTarget)
            .contentShape(Capsule(style: .continuous))
    }
}

public extension View {
    /// Applies standard capsule-pill metrics: vertical `oneUnit` padding, a
    /// `minimumHitTarget` height, and a capsule content shape.
    ///
    /// - Parameter horizontalPadding: Horizontal padding override. Defaults to
    ///   `theme.spacing.twoUnits`.
    func designPillMetrics(horizontalPadding: CGFloat? = nil) -> some View {
        modifier(PillMetrics(horizontalPadding: horizontalPadding))
    }
}
