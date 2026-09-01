import DesignSystem
import SwiftUI

/// A themed card that keeps a summary visible and reveals supporting detail on demand.
public struct DisclosureCard<Label: View, Detail: View>: View {
    @Binding private var isExpanded: Bool
    private let label: Label
    private let detail: Detail
    @Environment(\.designTheme) private var theme

    /// Creates a state-controlled disclosure card.
    ///
    /// - Parameters:
    ///   - isExpanded: A binding that controls whether detail is visible.
    ///   - label: Summary content that remains visible.
    ///   - detail: Supporting content revealed when expanded.
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder detail: () -> Detail
    ) {
        _isExpanded = isExpanded
        self.label = label()
        self.detail = detail()
    }

    /// The themed disclosure group.
    public var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            detail
        } label: {
            label
        }
        .padding(theme.spacing.twoUnits)
        .designCardSurface(showStroke: false)
    }
}

#Preview("Disclosure Card") {
    PreviewContent { theme in
        DisclosureCard(isExpanded: .constant(false)) {
            Text("Section title")
        } detail: {
            Text("Additional information shown when the section is expanded.")
        }
        .padding(theme.spacing.twoUnits)
    }
}
