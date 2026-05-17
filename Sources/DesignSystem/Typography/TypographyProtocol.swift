import SwiftUI

/// Semantic font tokens used by reusable components.
public protocol Typography: Sendable {
    /// Large title font, typically used for prominent screen headers.
    @MainActor var largeTitle: Font { get }
    /// Primary title font for section or screen headings.
    @MainActor var title: Font { get }
    /// Secondary title font for sub-section headings.
    @MainActor var title2: Font { get }
    /// Tertiary title font for smaller headings.
    @MainActor var title3: Font { get }
    /// Semibold font used for emphasized labels and navigation items.
    @MainActor var headline: Font { get }
    /// Standard body text font for primary content.
    @MainActor var body: Font { get }
    /// Callout font for supplementary text that sits alongside body content.
    @MainActor var callout: Font { get }
    /// Subheadline font for secondary descriptive text.
    @MainActor var subheadline: Font { get }
    /// Footnote font for ancillary information and attributions.
    @MainActor var footnote: Font { get }
    /// Caption font for labels, timestamps, and metadata.
    @MainActor var caption: Font { get }
    /// Smaller caption font for fine-print and legal text.
    @MainActor var caption2: Font { get }
    /// Font used for button labels.
    @MainActor var button: Font { get }
    /// Font used for interactive controls such as segmented pickers and steppers.
    @MainActor var control: Font { get }
    /// Compact font used for badges and status indicators.
    @MainActor var badge: Font { get }
    /// Font used for text input fields.
    @MainActor var field: Font { get }
}
