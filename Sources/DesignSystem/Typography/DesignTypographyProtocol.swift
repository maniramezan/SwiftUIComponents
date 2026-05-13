import SwiftUI

/// Semantic font tokens used by reusable components.
public protocol DesignTypography: Sendable {
    @MainActor var largeTitle: Font { get }
    @MainActor var title: Font { get }
    @MainActor var title2: Font { get }
    @MainActor var title3: Font { get }
    @MainActor var headline: Font { get }
    @MainActor var body: Font { get }
    @MainActor var callout: Font { get }
    @MainActor var subheadline: Font { get }
    @MainActor var footnote: Font { get }
    @MainActor var caption: Font { get }
    @MainActor var caption2: Font { get }
    @MainActor var button: Font { get }
    @MainActor var control: Font { get }
    @MainActor var badge: Font { get }
    @MainActor var field: Font { get }
}
