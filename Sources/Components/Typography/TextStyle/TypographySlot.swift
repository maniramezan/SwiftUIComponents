import DesignSystem
import SwiftUI

/// A type-safe reference to one slot on the active theme's `Typography` scale.
///
/// Reach for a slot wherever a component or call site would otherwise hand-pick a raw
/// `Font` value: the slot names the semantic rung of the type scale and leaves the
/// concrete `Font` to whichever `Typography` the surrounding `.designTheme(_:)`
/// installs. ``DesignText`` renders a string in a chosen slot; ``TypographySlot/font(_:)``
/// resolves the `Font` directly when a view needs the value itself.
///
/// Every case maps one-to-one to a member of the `Typography` protocol — the fifteen
/// base slots plus the fourteen weight-ladder variants derived from them — so a custom
/// `Typography` (custom font family included) flows through unchanged.
public enum TypographySlot: Sendable, CaseIterable {
    /// Resolves to `Typography.largeTitle`.
    case largeTitle
    /// Resolves to `Typography.title`.
    case title
    /// Resolves to `Typography.title2`.
    case title2
    /// Resolves to `Typography.title3`.
    case title3
    /// Resolves to `Typography.headline`.
    case headline
    /// Resolves to `Typography.body`.
    case body
    /// Resolves to `Typography.callout`.
    case callout
    /// Resolves to `Typography.subheadline`.
    case subheadline
    /// Resolves to `Typography.footnote`.
    case footnote
    /// Resolves to `Typography.caption`.
    case caption
    /// Resolves to `Typography.caption2`.
    case caption2
    /// Resolves to `Typography.button`.
    case button
    /// Resolves to `Typography.control`.
    case control
    /// Resolves to `Typography.badge`.
    case badge
    /// Resolves to `Typography.field`.
    case field

    /// Resolves to `Typography.largeTitleBold`.
    case largeTitleBold
    /// Resolves to `Typography.title2Bold`.
    case title2Bold
    /// Resolves to `Typography.title2Semibold`.
    case title2Semibold
    /// Resolves to `Typography.title3Bold`.
    case title3Bold
    /// Resolves to `Typography.title3Semibold`.
    case title3Semibold
    /// Resolves to `Typography.headlineSemibold`.
    case headlineSemibold
    /// Resolves to `Typography.bodySemibold`.
    case bodySemibold
    /// Resolves to `Typography.bodyMedium`.
    case bodyMedium
    /// Resolves to `Typography.subheadlineMedium`.
    case subheadlineMedium
    /// Resolves to `Typography.subheadlineSemibold`.
    case subheadlineSemibold
    /// Resolves to `Typography.footnoteSemibold`.
    case footnoteSemibold
    /// Resolves to `Typography.captionSemibold`.
    case captionSemibold
    /// Resolves to `Typography.captionBold`.
    case captionBold
    /// Resolves to `Typography.caption2Bold`.
    case caption2Bold

    /// The concrete `Font` this slot names on a given `Typography`.
    ///
    /// - Parameter typography: The type scale to resolve against, normally
    ///   `theme.typography` from `@Environment(\.designTheme)`.
    /// - Returns: The `Font` exposed by the matching `Typography` member.
    @MainActor
    public func font(_ typography: any Typography) -> Font {
        switch self {
        case .largeTitle: typography.largeTitle
        case .title: typography.title
        case .title2: typography.title2
        case .title3: typography.title3
        case .headline: typography.headline
        case .body: typography.body
        case .callout: typography.callout
        case .subheadline: typography.subheadline
        case .footnote: typography.footnote
        case .caption: typography.caption
        case .caption2: typography.caption2
        case .button: typography.button
        case .control: typography.control
        case .badge: typography.badge
        case .field: typography.field
        case .largeTitleBold: typography.largeTitleBold
        case .title2Bold: typography.title2Bold
        case .title2Semibold: typography.title2Semibold
        case .title3Bold: typography.title3Bold
        case .title3Semibold: typography.title3Semibold
        case .headlineSemibold: typography.headlineSemibold
        case .bodySemibold: typography.bodySemibold
        case .bodyMedium: typography.bodyMedium
        case .subheadlineMedium: typography.subheadlineMedium
        case .subheadlineSemibold: typography.subheadlineSemibold
        case .footnoteSemibold: typography.footnoteSemibold
        case .captionSemibold: typography.captionSemibold
        case .captionBold: typography.captionBold
        case .caption2Bold: typography.caption2Bold
        }
    }
}
