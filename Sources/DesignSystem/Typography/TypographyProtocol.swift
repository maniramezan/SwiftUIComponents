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

    // MARK: Weight variants

    /// Bold large title, for a hero heading that must outweigh a dense screen.
    @MainActor var largeTitleBold: Font { get }
    /// Bold secondary title, for a section heading that leads its own screen region.
    @MainActor var title2Bold: Font { get }
    /// Semibold secondary title, for a section heading that sits inside a larger group.
    @MainActor var title2Semibold: Font { get }
    /// Bold tertiary title, for the strongest heading available at a compact size.
    @MainActor var title3Bold: Font { get }
    /// Semibold tertiary title, for a card or row heading that stays below a section title.
    @MainActor var title3Semibold: Font { get }
    /// Semibold headline, for a heading that needs emphasis where `headline` is unweighted.
    @MainActor var headlineSemibold: Font { get }
    /// Semibold body, for a run of primary content that carries emphasis inline.
    @MainActor var bodySemibold: Font { get }
    /// Medium body, for a row label lifted a step without reading as a heading.
    @MainActor var bodyMedium: Font { get }
    /// Medium subheadline, for secondary text lifted a step above its neighbours.
    @MainActor var subheadlineMedium: Font { get }
    /// Semibold subheadline, for secondary text acting as a label for what follows.
    @MainActor var subheadlineSemibold: Font { get }
    /// Semibold footnote, for ancillary text that still has to be picked out at a glance.
    @MainActor var footnoteSemibold: Font { get }
    /// Semibold caption, the usual emphasis step for a small label.
    @MainActor var captionSemibold: Font { get }
    /// Bold caption, the heaviest step at caption size.
    ///
    /// For a small label that must hold its own beside body text rather than merely
    /// emphasise itself. Prefer ``captionSemibold`` for ordinary emphasis: at this size the
    /// step from semibold to bold is small, so reach for bold only when the label competes
    /// with larger text next to it.
    @MainActor var captionBold: Font { get }
    /// Bold secondary caption, for fine print that doubles as a marker or count.
    @MainActor var caption2Bold: Font { get }
}

/// Weight variants derived from each conformer's own base slots.
///
/// Supplying them here keeps the ladder additive: a conformer inherits every variant from
/// the slot it is built on — including any custom font family — and overrides only the ones
/// whose weight its type scale defines differently.
extension Typography {
    /// Bold large title, derived from ``largeTitle``.
    @MainActor public var largeTitleBold: Font { largeTitle.bold() }
    /// Bold secondary title, derived from ``title2``.
    @MainActor public var title2Bold: Font { title2.bold() }
    /// Semibold secondary title, derived from ``title2``.
    @MainActor public var title2Semibold: Font { title2.weight(.semibold) }
    /// Bold tertiary title, derived from ``title3``.
    @MainActor public var title3Bold: Font { title3.bold() }
    /// Semibold tertiary title, derived from ``title3``.
    @MainActor public var title3Semibold: Font { title3.weight(.semibold) }
    /// Semibold headline, derived from ``headline``.
    @MainActor public var headlineSemibold: Font { headline.weight(.semibold) }
    /// Semibold body, derived from ``body``.
    @MainActor public var bodySemibold: Font { body.weight(.semibold) }
    /// Medium body, derived from ``body``.
    @MainActor public var bodyMedium: Font { body.weight(.medium) }
    /// Medium subheadline, derived from ``subheadline``.
    @MainActor public var subheadlineMedium: Font { subheadline.weight(.medium) }
    /// Semibold subheadline, derived from ``subheadline``.
    @MainActor public var subheadlineSemibold: Font { subheadline.weight(.semibold) }
    /// Semibold footnote, derived from ``footnote``.
    @MainActor public var footnoteSemibold: Font { footnote.weight(.semibold) }
    /// Semibold caption, derived from ``caption``.
    @MainActor public var captionSemibold: Font { caption.weight(.semibold) }
    /// Bold caption, derived from ``caption``.
    @MainActor public var captionBold: Font { caption.bold() }
    /// Bold secondary caption, derived from ``caption2``.
    @MainActor public var caption2Bold: Font { caption2.bold() }
}
