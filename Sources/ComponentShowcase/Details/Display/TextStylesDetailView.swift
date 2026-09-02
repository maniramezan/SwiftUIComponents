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

#Preview {
    ScrollView {
        TextStylesDetailView()
            .padding()
    }
}
