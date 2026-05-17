import DesignSystem
import SwiftUI

/// A solid skeleton block sized to match a real piece of UI, used while that
/// content loads.
///
/// `GhostLoadingBlock` renders a single rounded rectangle filled with the
/// current theme's `containerSecondary` color. Compose several blocks
/// together to mirror the shape of the eventual layout so users perceive the
/// page settling rather than popping in.
///
/// ```swift
/// VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
///     GhostLoadingBlock(width: 160, height: 16)
///     GhostLoadingBlock(height: 88, cornerRadius: theme.radius.oneAndHalfUnits)
/// }
/// ```
///
/// The block is hidden from accessibility (`accessibilityHidden(true)`); pair
/// the surrounding container with a single `accessibilityLabel` such as
/// `"Loading"` so VoiceOver users hear one announcement instead of several
/// empty rectangles.
public struct GhostLoadingBlock: View {

    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat?
    @Environment(\.designTheme) private var theme

    /// Creates a skeleton block.
    ///
    /// - Parameters:
    ///   - width: Optional fixed width. Pass `nil` to fill the available
    ///     horizontal space.
    ///   - height: Fixed height for the block, in points.
    ///   - cornerRadius: Optional corner radius override. When `nil`, the
    ///     block uses the current theme's `radius.oneUnit` (8 pt by default).
    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat? = nil
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        let radius = cornerRadius ?? theme.radius.oneUnit
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(theme.colors.containerSecondary)
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

#Preview("Ghost Loading Block") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            GhostLoadingBlock(width: 160, height: theme.spacing.twoUnits)
            GhostLoadingBlock(
                height: theme.spacing.sixUnits + theme.spacing.fiveUnits,
                cornerRadius: theme.radius.twoUnits
            )
            GhostLoadingBlock(height: theme.spacing.threeUnits)
        }
        .padding(theme.spacing.twoUnits)
    }
}
