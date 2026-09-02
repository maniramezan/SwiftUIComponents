import Components
import DesignSystem
import SwiftUI

struct TextStylesDetailView: View {
    @Environment(\.designTheme) private var theme

    private let styles: [(label: String, role: TextRole)] = [
        ("Title", .title),
        ("Headline", .headline),
        ("Body", .body),
        ("Secondary", .secondary),
        ("Caption", .caption),
        ("Error", .error),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("All text roles") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ForEach(styles, id: \.label) { item in
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.label)
                                .designTextStyle(item.role)
                            Spacer()
                            Text(".\(item.label.lowercased().replacingOccurrences(of: " ", with: ""))")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        if item.label != styles.last?.label {
                            Divider()
                        }
                    }
                }
            }

            ShowcaseSection("DesignText — pick a slot") {
                DesignTextPlayground()
            }

            ShowcaseSection("Typography weight ladder") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ForEach(WeightLadderSample.all) { sample in
                        HStack(alignment: .firstTextBaseline) {
                            Text("The quick brown fox")
                                .font(sample.font(theme.typography))
                            Spacer()
                            Text(sample.name)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        if sample.id != WeightLadderSample.all.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

/// One entry in the `Typography` weight-ladder showcase, pairing the token name with a
/// resolver so the row renders in the exact font the token exposes.
private struct WeightLadderSample: Identifiable {
    let name: String
    let font: @MainActor (any Typography) -> Font
    var id: String { name }

    static let all: [WeightLadderSample] = [
        .init(name: "largeTitleBold") { $0.largeTitleBold },
        .init(name: "title2Bold") { $0.title2Bold },
        .init(name: "title2Semibold") { $0.title2Semibold },
        .init(name: "title3Bold") { $0.title3Bold },
        .init(name: "title3Semibold") { $0.title3Semibold },
        .init(name: "headlineSemibold") { $0.headlineSemibold },
        .init(name: "bodySemibold") { $0.bodySemibold },
        .init(name: "bodyMedium") { $0.bodyMedium },
        .init(name: "subheadlineMedium") { $0.subheadlineMedium },
        .init(name: "subheadlineSemibold") { $0.subheadlineSemibold },
        .init(name: "footnoteSemibold") { $0.footnoteSemibold },
        .init(name: "captionSemibold") { $0.captionSemibold },
        .init(name: "captionBold") { $0.captionBold },
        .init(name: "caption2Bold") { $0.caption2Bold },
    ]
}

/// Live controls for ``DesignText``: choose any ``TypographySlot`` and edit the sample
/// string, then see the rendered result in that slot's themed font.
private struct DesignTextPlayground: View {
    @State private var slot: TypographySlot = .body
    @State private var sample: String = "The quick brown fox"
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneAndHalfUnits) {
            Picker("Slot", selection: $slot) {
                ForEach(Self.slots, id: \.slot) { entry in
                    Text(entry.name).tag(entry.slot)
                }
            }

            TextField("Sample text", text: $sample)
                .textFieldStyle(.roundedBorder)

            DesignText(verbatim: sample, slot: slot)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Every ``TypographySlot`` paired with the token name it maps to, in ladder order.
    private static let slots: [(name: String, slot: TypographySlot)] = [
        ("largeTitle", .largeTitle), ("title", .title), ("title2", .title2),
        ("title3", .title3), ("headline", .headline), ("body", .body),
        ("callout", .callout), ("subheadline", .subheadline), ("footnote", .footnote),
        ("caption", .caption), ("caption2", .caption2), ("button", .button),
        ("control", .control), ("badge", .badge), ("field", .field),
        ("largeTitleBold", .largeTitleBold), ("title2Bold", .title2Bold),
        ("title2Semibold", .title2Semibold), ("title3Bold", .title3Bold),
        ("title3Semibold", .title3Semibold), ("headlineSemibold", .headlineSemibold),
        ("bodySemibold", .bodySemibold), ("bodyMedium", .bodyMedium),
        ("subheadlineMedium", .subheadlineMedium),
        ("subheadlineSemibold", .subheadlineSemibold),
        ("footnoteSemibold", .footnoteSemibold), ("captionSemibold", .captionSemibold),
        ("captionBold", .captionBold), ("caption2Bold", .caption2Bold),
    ]
}

#Preview {
    ScrollView {
        TextStylesDetailView()
            .padding()
    }
}
